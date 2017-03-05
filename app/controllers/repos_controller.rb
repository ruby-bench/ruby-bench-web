class ReposController < ApplicationController
  before_action :find_organization_by_name
  before_action :find_organization_repo_by_name

  def index
    @charts =
      if charts = $redis.get("sparklines:#{@repo.id}")
        MessagePack.unpack(charts, symbolize_keys: true).with_indifferent_access
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

        if (cache_read_msgpack = $redis.get(cache_key))
          cache_read = MessagePack.unpack(cache_read_msgpack, symbolize_keys: true)
          ChartBuilder.construct_from_cache(cache_read, benchmark_result_type)
        else
          benchmark_runs = BenchmarkRun.fetch_commit_benchmark_runs(
            @form_result_type, benchmark_result_type, @benchmark_run_display_count
          )

          next if benchmark_runs.empty?

          runs = benchmark_runs.sort_by { |run| run.initiator.created_at }
          chart_builder = ChartBuilder.new(runs, benchmark_result_type)

          chart_builder.build_columns do |benchmark_run|
            environment = YAML.load(benchmark_run.environment)
            commit = benchmark_run.initiator

            version = {
              commit_sha: commit.sha1[0..6],
              commit_date: commit.created_at.to_s,
              commit_message: commit.message.truncate(30)
            }
            # If there is more information about the environment, we add it to `version` 
            if environment.is_a?(Hash)
              version.merge!(environment)
            else
              version[:environment] = environment
            end

            version
          end

          $redis.set(cache_key, {
            datasets: chart_builder.columns,
            versions: chart_builder.categories
          }.to_msgpack)
          chart_builder
        end
      end.compact
    end

    @result_types = fetch_categories if request.format.html?
    @benchmark_name = params[:result_type].to_s
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
            version.merge!(environment)
          else
            version[:environment] = environment
          end

          version
        end
      end.compact
    end

    @result_types = fetch_categories if request.format.html?
    @benchmark_name = params[:result_type].to_s
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
