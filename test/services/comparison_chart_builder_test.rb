require 'test_helper'

class ComparisonChartBuilderTest < ActiveSupport::TestCase
  setup do
    @benchmark_result_type = create(:benchmark_result_type)
    @benchmark_types = create_list(:benchmark_type, 3)
    @benchmark_types.each do |benchmark_type|
      5.times do
        create(
          :commit_benchmark_run,
          benchmark_type: benchmark_type,
          benchmark_result_type: @benchmark_result_type
        )
      end
    end
    @chart_builder = ComparisonChartBuilder.new(@benchmark_result_type, @benchmark_types)
  end

  test '#series' do
    @benchmark_types.each do |benchmark_type|
      assert_includes @chart_builder.series, series_for(benchmark_type)
    end
  end

  test '#unit' do
    assert @chart_builder.unit, @benchmark_result_type.unit
  end

  test '#name' do
    assert @chart_builder.name, @benchmark_result_type.name
  end

  test '#construct_from_cache' do
    cache_read = { series: [{ name: 'series1', data: [1, 2, 3] }] }
    chart_builder = ComparisonChartBuilder.construct_from_cache(cache_read, @benchmark_result_type)

    assert chart_builder.series = cache_read[:series]
  end

  private

  def series_for(benchmark_type)
    {
      name: benchmark_type.category,
      data:
        BenchmarkRun.fetch_commit_benchmark_runs(
          benchmark_type.category,
          @benchmark_result_type,
          nil
        ).sort_by { |run| run.initiator.created_at }
        .map { |run| [run.initiator.created_at.to_i * 1000, run.result.values[0].to_i] }
    }
  end
end
