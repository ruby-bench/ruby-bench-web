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
      @charts = @benchmark.result_types.map do |result_type|
        chart_for(result_type)
      end.compact
    end
  end

  def releases
    unless @benchmark.blank?
      @charts = @benchmark.result_types.map do |result_type|
        benchmark_runs = BenchmarkRun.fetch_release_benchmark_runs(
          @benchmark.label, result_type
        )

        next if benchmark_runs.empty?
        benchmark_runs = BenchmarkRun.sort_by_initiator_version(benchmark_runs)
        if latest_benchmark_run = BenchmarkRun.latest_commit_benchmark_run(@benchmark.label, result_type)
          benchmark_runs << latest_benchmark_run
        end

        chart_builder = ChartBuilder.new(benchmark_runs, result_type)
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

  def chart_for(result_type)
    if already_cached?(result_type)
      chart_from_cache(result_type)
    else
      build_and_cache_chart(result_type)
    end
  end

  def already_cached?(result_type)
    $redis.exists(@cache_keys[result_type])
  end

  def chart_from_cache(result_type)
    packed_chart = $redis.get(@cache_keys[result_type])
    unpacked_chart = MessagePack.unpack(packed_chart, symbolize_keys: true)
    ChartBuilder.construct_from_cache(unpacked_chart, result_type)
  end

  def build_and_cache_chart(result_type)
    benchmark_runs = benchmark_runs_for(result_type)

    unless benchmark_runs.empty?
      chart = build_chart(benchmark_runs, result_type)
      cache(chart, result_type)

      chart
    else
      nil
    end
  end

  def benchmark_runs_for(result_type)
    BenchmarkRun
      .fetch_commit_benchmark_runs(@benchmark.label, result_type, @display_count)
      .sort_by { |run| run.initiator.created_at }
  end

  def comparing_runs_for(result_type)
    BenchmarkRun
      .fetch_commit_benchmark_runs(@comparing_benchmark.label, result_type, @display_count)
      .sort_by { |run| run.initiator.created_at }
  end

  def build_chart(benchmark_runs, result_type)
    comparing_runs = comparing_runs_for(result_type) if @comparing_benchmark.present?

    chart_builder = ChartBuilder.new(
      benchmark_runs,
      result_type,
      comparing_runs
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

  def cache(chart, result_type)
    $redis.set(
      @cache_keys[result_type],
      {
        datasets: chart.columns,
        versions: chart.categories
      }.to_msgpack
    )
  end

  def set_organization
    @organization = Organization.find_by_name(params[:organization_name]) || not_found
  end

  def set_repo
    @repo = @organization.repos.find_by_name(params[:repo_name]) || not_found
  end

  def set_benchmark
    @benchmark = @repo.benchmarks.find_by_category(params[:result_type])
  end

  def set_benchmark_to_compare_with
    @comparing_benchmark = Benchmark.find_by_category(params[:compare_with])
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
    @benchmarks = @repo.benchmarks
  end

  def set_comparable_benchmarks
    @comparable_benchmarks =
      if @benchmark.present?
        Benchmark.all_except(@benchmark)
      else
        []
      end
  end

  def set_redis_cache_keys
    unless @benchmark.blank?
      @cache_keys = {}

      @benchmark.result_types.each do |result_type|
        @cache_keys[result_type] =
          if @comparing_benchmark.present?
            "#{BenchmarkRun.charts_cache_key(@benchmark, result_type)}:#{@display_count}:#{BenchmarkRun.charts_cache_key(@comparing_benchmark, result_type)}"
          else
            "#{BenchmarkRun.charts_cache_key(@benchmark, result_type)}:#{@display_count}"
          end
      end
    end
  end
end
