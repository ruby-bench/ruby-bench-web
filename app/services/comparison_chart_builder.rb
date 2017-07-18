class ComparisonChartBuilder
  attr_accessor :series

  def self.construct_from_cache(cache_read, benchmark_result_type)
    chart_builder = new(benchmark_result_type, [])
    chart_builder.series = cache_read[:series]

    chart_builder
  end

  def initialize(benchmark_result_type, benchmark_types)
    @benchmark_types = benchmark_types
    @benchmark_result_type = benchmark_result_type
    @series = build_series if benchmark_types.present?
  end

  def unit
    @benchmark_result_type.unit
  end

  def name
    @benchmark_result_type.name
  end

  private

  def build_series
    series = @benchmark_types.map do |benchmark_type|
      {
        name: benchmark_type.category,
        data: runs_for(benchmark_type)
      }
    end

    strech_out(series)
  end

  def strech_out(series)
    xmin = series.first[:data].first.first
    xmax = series.first[:data].last.first

    series.each do |s|
      s_xmin = s[:data].first.first
      s_xmax = s[:data].last.first

      xmin = s_xmin if s_xmin < xmin
      xmax = s_xmax if s_xmax > xmax
    end

    series.each do |s|
      s[:data].insert(0, [xmin, s[:data].first.second]) if s[:data].first.first != xmin
      s[:data].push([xmax, s[:data].last.second]) if s[:data].last.first != xmax
    end

    series
  end

  def runs_for(benchmark_type)
    BenchmarkRun.fetch_commit_benchmark_runs(
      benchmark_type.category,
      @benchmark_result_type,
      nil
    ).sort_by { |run| run.initiator.created_at }
    .map { |run| [run.initiator.created_at.to_i * 1000, run.result.values[0].to_i] }
  end
end
