require 'test_helper'

class ComparisonChartBuilderTest < ActiveSupport::TestCase
  setup do
    Commit.record_timestamps = false
    @benchmark_result_type = create(:benchmark_result_type)
    @benchmark_types = create_list(:benchmark_type, 3)
    @benchmark_types.each do |benchmark_type|
      5.times do |i|
        create(
          :benchmark_run,
          benchmark_type: benchmark_type,
          benchmark_result_type: @benchmark_result_type,
          initiator: create(:commit, created_at: Time.at(i + 1), updated_at: Time.at(i + 1))
        )
      end
    end
  end

  test 'series' do
    chart_builder = ComparisonChartBuilder.new(@benchmark_result_type, @benchmark_types)
    @benchmark_types.each do |benchmark_type|
      assert_includes chart_builder.series, series_for(benchmark_type)
    end
  end

  test 'series with irregular time intervals' do
    xmin = 0
    xmax = 6
    create(
      :benchmark_run,
      benchmark_type: @benchmark_types.first,
      benchmark_result_type: @benchmark_result_type,
      initiator: create(:commit, created_at: Time.at(xmin), updated_at: Time.at(xmin))
    )
    create(
      :benchmark_run,
      benchmark_type: @benchmark_types.first,
      benchmark_result_type: @benchmark_result_type,
      initiator: create(:commit, created_at: Time.at(xmax), updated_at: Time.at(xmax))
    )
    chart_builder = ComparisonChartBuilder.new(@benchmark_result_type, @benchmark_types)
    @benchmark_types.each do |benchmark_type|
      assert_includes chart_builder.series, streched_series(benchmark_type, min: xmin, max: xmax)
    end
  end

  test 'commit_urls' do
    chart_builder = ComparisonChartBuilder.new(@benchmark_result_type, @benchmark_types)
    @benchmark_types.each do |benchmark_type|
      assert_includes chart_builder.commit_urls, commit_urls_for(benchmark_type)
    end
  end

  test 'unit' do
    chart_builder = ComparisonChartBuilder.new(@benchmark_result_type, @benchmark_types)
    assert chart_builder.unit, @benchmark_result_type.unit
  end

  test 'name' do
    chart_builder = ComparisonChartBuilder.new(@benchmark_result_type, @benchmark_types)
    assert chart_builder.name, @benchmark_result_type.name
  end

  test 'construct_from_cache' do
    cache_read = {
      series: [
        { name: 'series1', data: [1, 2, 3] }
      ],
      commit_urls: [
        { name: 'first', data: [ 'link1', 'link2' ] }
      ]
    }
    chart_builder = ComparisonChartBuilder.construct_from_cache(cache_read, @benchmark_result_type)

    assert chart_builder.series = cache_read[:series]
    assert chart_builder.commit_urls = cache_read[:commit_urls]
  end

  teardown do
    Commit.record_timestamps = true
  end

  private

  def series_for(benchmark_type)
    {
      name: benchmark_type.category,
      data:
        BenchmarkRun
          .fetch_commit_benchmark_runs(benchmark_type.category, @benchmark_result_type, nil)
          .sort_by { |run| run.initiator.created_at }
          .map { |run| [run.initiator.created_at.to_i * 1000, run.result.values[0].to_i] }
    }
  end

  def streched_series(benchmark_type, min:, max:)
    series = series_for(benchmark_type)
    series[:data].insert(0, [min * 1000, 5]) unless series[:data].first.first == min * 1000
    series[:data].push([max * 1000, 5]) unless series[:data].last.first == max * 1000
    series
  end

  def commit_urls_for(benchmark_type)
    {
      name: benchmark_type.category,
      data:
        BenchmarkRun
          .fetch_commit_benchmark_runs(benchmark_type.category, @benchmark_result_type, nil)
          .sort_by { |run| run.initiator.created_at }
          .map do |run|
            commit = run.initiator
            repo = commit.repo
            organization = repo.organization

            "https://github.com/#{organization.name}/#{repo.name}/commit/#{commit.sha1}"
          end
    }
  end
end
