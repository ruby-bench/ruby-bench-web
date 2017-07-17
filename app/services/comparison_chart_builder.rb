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
    @series = @benchmark_types.map do |benchmark_type|
      {
        name: benchmark_type.category,
        data: runs_for(benchmark_type)
      }
    end
  end

  def unit
    @benchmark_result_type.unit
  end

  def name
    @benchmark_result_type.name
  end

  private

  def runs_for(benchmark_type)
    BenchmarkRun.fetch_commit_benchmark_runs(
      benchmark_type.category,
      @benchmark_result_type,
      nil
    ).sort_by { |run| run.initiator.created_at }
    .map { |run| [run.initiator.created_at.to_i * 1000, run.result.values[0].to_i] }
  end
end
