class ReposController < ApplicationController
  before_action :find_organization_by_name
  before_action :find_organization_repo_by_name

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

      # read versions from cache since it's shared among all `@charts`
      version_cache_key = "charts:#{@benchmark_type.id}:#{@benchmark_run_display_count}"
      versions = $redis.get(version_cache_key)
      @versions = JSON.parse(versions) if versions

      versions_calculate_once = ActiveSupport::OrderedHash.new
      @charts = @benchmark_type.benchmark_result_types.map do |benchmark_result_type|
        cache_key = "#{BenchmarkRun.charts_cache_key(@benchmark_type, benchmark_result_type)}:#{@benchmark_run_display_count}"

        if (columns = $redis.get(cache_key)) && (versions)
          [JSON.parse(columns).symbolize_keys!, benchmark_result_type]
        else
          benchmark_runs = BenchmarkRun.fetch_commit_benchmark_runs(
            @form_result_type, benchmark_result_type, @benchmark_run_display_count
          )

          next if benchmark_runs.empty?

          chart_builder = ChartBuilder.new(benchmark_runs.sort_by do |benchmark_run|
            benchmark_run.initiator.created_at
          end)

          columns = chart_builder.build_columns do |benchmark_run|
            environment = YAML.load(benchmark_run.environment)

            commit = benchmark_run.initiator

            # generate the version object
            config = {
              commit: commit.sha1[0..6],
              commit_date: commit.created_at,
              commit_message: commit.message.truncate(30)
            }
            if environment.is_a?(Hash)
              config.merge!(environment)
              # solely for the purpose of generating the correct HTML
              environment = hash_to_html(environment)
            else
              config[:environment] = environment
            end

            versions_calculate_once[config[:commit]] ||= config

            # generate HTML
            "Commit: #{config[:commit]}<br>" \
            "Commit Date: #{config[:commit_date]}<br>" \
            "Commit Message: #{config[:commit_message]}<br>" \
            "#{environment}"
          end
          @versions ||= versions_calculate_once.values

          $redis.set(cache_key, columns.to_json)
          # cache the `@versions` as well
          $redis.set(version_cache_key, @versions.to_json)
          [columns, benchmark_result_type]
        end
      end.compact
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_categories
      end
      format.json { render json: generate_json(@charts, @versions) }
      format.js
    end
  end

  def show_releases
    if (@form_result_type = params[:result_type]) &&
       (@benchmark_type = find_benchmark_type_by_category(@form_result_type))

      versions_calculate_once = ActiveSupport::OrderedHash.new
      @charts = @benchmark_type.benchmark_result_types.map do |benchmark_result_type|
        benchmark_runs = BenchmarkRun.fetch_release_benchmark_runs(
          @form_result_type, benchmark_result_type
        )

        next if benchmark_runs.empty?
        benchmark_runs = BenchmarkRun.sort_by_initiator_version(benchmark_runs)

        if latest_benchmark_run = BenchmarkRun.latest_commit_benchmark_run(@benchmark_type, benchmark_result_type)
          benchmark_runs << latest_benchmark_run
        end

        columns = ChartBuilder.new(benchmark_runs).build_columns do |benchmark_run|
          environment = YAML.load(benchmark_run.environment)

          # generate the version object
          config = { version: benchmark_run.initiator.version }
          if environment.is_a?(Hash)
            config.merge!(environment)
            # solely for the purpose of generating the correct HTML
            environment = hash_to_html(environment)
          else
            config[:environment] = environment
          end

          versions_calculate_once[config[:version]] ||= config

          # generate HTML
          "Version: #{config[:version]}<br>" \
          "#{environment}"
        end
        @versions ||= versions_calculate_once.values

        [columns, benchmark_result_type]
      end.compact
    end

    respond_to do |format|
      format.html do
        @result_types = fetch_categories
      end
      format.json { render json: generate_json(@charts, @versions) }
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

  # Generate the JSON representation of `charts`
  def generate_json(charts, versions)
    charts.map do |chart|
      # rename for clarity
      result_data = chart[0]
      result_type = chart[1]

      datapoints = []
      variations = []
      # each column contains an array of datapoints
      JSON.parse(result_data[:columns]).each do |column| 
        # get one set of datapoints (sometimes there's 2+ sets of data for one chart)
        datapoints << column['data']
        # This is for when there are two data sets in one chart (ex. rails commits benchmarks)
        # Example variations: `with_prepared_statements`, `without_prepared_statements`
        # `column['name']` is the benchmark name when there is only one set of datapoints
        variations << column['name']
      end

      # generate the json
      config = {
        benchmark_name: params[:result_type],
        datapoints: datapoints,
        "#{@repo.name}_versions".to_sym => versions,
        measurement: result_type[:name],
        unit: result_type[:unit]
      }
      config[:variations] = variations if variations.length > 1
      config
    end
  end

  # Generate an HTML string representing the `hash`, with each pair on a new line
  def hash_to_html(hash)
    hash.map do |k, v|
      "#{k}: #{v}" 
    end.join("<br>")
  end
end
