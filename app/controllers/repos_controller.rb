class ReposController < ApplicationController
  before_action :find_organization_by_name
  before_action :find_organization_repo_by_name

  include JSONGenerator

  def index
    @charts =
      if charts = $redis.get("sparklines:#{@repo.id}")
        JSON.parse(charts).with_indifferent_access
      else
        @repo.generate_sparkline_data
      end
  end

  def show
    display_count = params[:display_count].to_i

    @benchmark_run_display_count =
      if BenchmarkRun::PAGINATE_COUNT.include?(display_count)
        display_count
      else
        BenchmarkRun::DEFAULT_PAGINATE_COUNT
      end

    if (@form_result_type = params[:result_type]) &&
       (@benchmark_type = find_benchmark_type_by_category(@form_result_type))

      @charts = @benchmark_type.benchmark_result_types.map do |benchmark_result_type|
        cache_key = "#{BenchmarkRun.charts_cache_key(@benchmark_type, benchmark_result_type)}:#{@benchmark_run_display_count}"

        if (cache_read_json = $redis.get(cache_key))
          cache_read = JSON.parse(cache_read_json, symbolize_names: true)
          ChartBuilder.new([], benchmark_result_type).construct_from_cache(cache_read)
        else
          benchmark_runs = BenchmarkRun.fetch_commit_benchmark_runs(
            @form_result_type, benchmark_result_type, @benchmark_run_display_count
          )

          next if benchmark_runs.empty?

          chart_builder = ChartBuilder.new(benchmark_runs.sort_by do |benchmark_run|
            benchmark_run.initiator.created_at
          end, benchmark_result_type)

          chart_builder.build_columns do |benchmark_run|
            environment = YAML.load(benchmark_run.environment)
            commit = benchmark_run.initiator

            version = {
              commit: commit.sha1[0..6],
              commit_date: commit.created_at,
              commit_message: commit.message.truncate(30)
            }
            # If there is more information about the environment, we add it to `version` 
            if environment.is_a?(Hash)
              # Use the key(s) in `environment` instead of setting `version[:environment]`
              version.merge!(environment)
            else
              # If `environment` is not a Hash, then it is not JSON friendly, so we need to make
              #   a new key in `version`
              version[:environment] = environment
            end

            # this return values gets appended to ChartBuilder#@versions
            version
          end

          $redis.set(cache_key, {
            datasets: JSON.parse(chart_builder.data[:columns]),
            versions: chart_builder.versions
          }.to_json)
          chart_builder
        end
      end.compact
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_categories
      end
      format.json { render json: generate_json(@charts, params) }
      format.js
    end
  end

  def show_releases
    if (@form_result_type = params[:result_type]) &&
       (@benchmark_type = find_benchmark_type_by_category(@form_result_type))

      @charts = @benchmark_type.benchmark_result_types.map do |benchmark_result_type|
        benchmark_runs = BenchmarkRun.fetch_release_benchmark_runs(
          @form_result_type, benchmark_result_type
        )

        next if benchmark_runs.empty?
        benchmark_runs = BenchmarkRun.sort_by_initiator_version(benchmark_runs)

        if latest_benchmark_run = BenchmarkRun.latest_commit_benchmark_run(@benchmark_type, benchmark_result_type)
          benchmark_runs << latest_benchmark_run
        end

        chart_builder = ChartBuilder.new(benchmark_runs, benchmark_result_type)
        chart_builder.build_columns do |benchmark_run|
          environment = YAML.load(benchmark_run.environment)

          version = { version: benchmark_run.initiator.version }

          # If there is more information about the environment, we add it to `version` 
          if environment.is_a?(Hash)
            # Use the key(s) in `environment` instead of setting `version[:environment]`
            version.merge!(environment)
          else
            # If `environment` is not a Hash, then it is not JSON friendly, so we need to make
            #   a new key in `version`
            version[:environment] = environment
          end

          # this return values gets appended to ChartBuilder#@versions
          version
        end

        chart_builder
      end.compact
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_categories
      end
      format.json { render json: generate_json(@charts, params) }
      format.js
    end
  end

  private

  def find_organization_by_name
    @organization = Organization.find_by_name(params[:organization_name]) || not_found
  end

  def find_organization_repo_by_name
    @repo = @organization.repos.find_by_name(params[:repo_name]) || not_found
  end

  def find_benchmark_type_by_category(category)
    @repo.benchmark_types.find_by_category(category)
  end

  def fetch_categories
    @repo.benchmark_types.pluck(:category)
  end
end
