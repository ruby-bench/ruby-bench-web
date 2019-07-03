class ReposController < ApplicationController
  require 'net/http' if Rails.env.development?

  before_action :set_organization
  before_action :set_repo
  before_action :set_benchmark
  before_action :set_benchmark_to_compare_with
  before_action :set_display_count
  before_action :set_repo_benchmarks
  before_action :set_comparable_benchmarks
  before_action :set_redis_cache_keys

  def index
    @charts =
      if charts = $redis.get("sparklines:#{@repo.id}")
        MessagePack.unpack(charts, symbolize_keys: true).with_indifferent_access
      else
        @repo.generate_sparkline_data
      end
  end

  def commits
    unless @benchmark.blank?
      @charts = ips_first(@benchmark.benchmark_result_types).map do |benchmark_type|
        chart_for(benchmark_type)
      end.compact
    end
  end

  def releases
    unless @benchmark.blank?
      @charts = ips_first(@benchmark.benchmark_result_types).map do |benchmark_result_type|
        benchmark_runs = BenchmarkRun.fetch_release_benchmark_runs(
          @benchmark, benchmark_result_type
        )

        next if benchmark_runs.empty?
        benchmark_runs = BenchmarkRun.sort_by_initiator_version(benchmark_runs)
        if latest_benchmark_run = BenchmarkRun.latest_commit_benchmark_run(@benchmark.category, benchmark_result_type)
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
  end

  private

  def chart_for(benchmark_type)
    if already_cached?(benchmark_type)
      chart_from_cache(benchmark_type)
    else
      build_and_cache_chart(benchmark_type)
    end
  end

  def already_cached?(benchmark_type)
    $redis.exists(@cache_keys[benchmark_type])
  end

  def chart_from_cache(benchmark_type)
    packed_chart = $redis.get(@cache_keys[benchmark_type])
    unpacked_chart = MessagePack.unpack(packed_chart, symbolize_keys: true)
    if @comparing_benchmark.present?
      ComparisonChartBuilder.construct_from_cache(unpacked_chart, benchmark_type)
    else
      ChartBuilder.construct_from_cache(unpacked_chart, benchmark_type)
    end
  end

  def build_and_cache_chart(benchmark_type)
    chart = build_chart(benchmark_type)
    cache(chart, benchmark_type)

    chart
  end

  def benchmark_runs_for(benchmark_type)
    BenchmarkRun
      .fetch_commit_benchmark_runs(@benchmark.category, benchmark_type, @display_count)
      .sort_by { |run| run.initiator.created_at }
  end

  def build_chart(benchmark_type)
    if @comparing_benchmark.present?
      ComparisonChartBuilder.new(benchmark_type, [@benchmark, @comparing_benchmark])
    else
      benchmark_runs = benchmark_runs_for(benchmark_type)

      chart_builder = ChartBuilder.new(
        benchmark_runs,
        benchmark_type,
      )

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

      chart_builder
    end
  end

  def cache(chart, benchmark_type)
    if @comparing_benchmark.present?
      cache_comparison(chart, benchmark_type)
    else
      $redis.set(
        @cache_keys[benchmark_type],
        {
          datasets: chart.columns,
          versions: chart.categories
        }.to_msgpack
      )
    end
  end

  def cache_comparison(chart, benchmark_type)
    $redis.set(
      @cache_keys[benchmark_type],
      {
        series: chart.series,
        commit_urls: chart.commit_urls
      }.to_msgpack
    )
  end

  def comparing_runs_for(benchmark_type)
    BenchmarkRun
      .fetch_commit_benchmark_runs(@comparing_benchmark.category, benchmark_type, @display_count)
      .sort_by { |run| run.initiator.created_at }
  end

  def set_organization
    @organization = Organization.find_by_name(params[:organization_name]) || not_found
  end

  def set_repo
    @repo = @organization.repos.find_by_name(params[:repo_name]) || not_found
  end

  def set_benchmark
    @benchmark = @repo.benchmark_types.find_by_category(params[:result_type])
  end

  def set_benchmark_to_compare_with
    @comparing_benchmark = BenchmarkType.find_by_category(params[:compare_with])
  end

  def set_display_count
    @display_count =
      if BenchmarkRun::PAGINATE_COUNT.include?(params[:display_count].to_i)
        if @comparing_benchmark.present? && params[:display_count].to_i > 500
          500
        else
          params[:display_count].to_i
        end
      else
        if @comparing_benchmark.present?
          500
        else
          BenchmarkRun::DEFAULT_PAGINATE_COUNT
        end
      end
  end

  def set_repo_benchmarks
    @benchmarks = @repo.benchmark_types
    set_rubybench_benchmarks
    set_users_benchmarks
    @benchmarks
  end

  def set_rubybench_benchmarks
    @rubybench_benchmarks = @benchmarks.where(from_user: false)
  end

  def set_users_benchmarks
    @users_benchmarks = @benchmarks.where(from_user: true)
  end

  def set_comparable_benchmarks
    @comparable_benchmarks =
      if @benchmark.present?
        @benchmark.comparison_benchmark_types
      else
        []
      end
  end

  def set_redis_cache_keys
    unless @benchmark.blank?
      @cache_keys = {}

      @benchmark.benchmark_result_types.each do |benchmark_type|
        @cache_keys[benchmark_type] =
          if @comparing_benchmark.present?
            "#{BenchmarkRun.charts_cache_key(@benchmark, benchmark_type)}:#{BenchmarkRun.charts_cache_key(@comparing_benchmark, benchmark_type)}"
          else
            "#{BenchmarkRun.charts_cache_key(@benchmark, benchmark_type)}:#{@display_count}"
          end
      end
    end
  end

  # i/s is a new metric but I want to see it first
  def ips_first(result_types)
    ips, others = result_types.partition { |t| t.unit == 'i/s' }
    [*ips, *others]
  end
end
