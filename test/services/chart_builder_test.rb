require 'test_helper'

class ChartBuilderTest < ActiveSupport::TestCase
  test "#build_columns" do
    benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    other_benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    chart_builder = ChartBuilder.new([benchmark_run, other_benchmark_run], benchmark_run.benchmark_result_type)

    chart_builder2 = chart_builder.build_columns do |benchmark_run|
      { commit: benchmark_run.initiator.sha1 }
    end

    assert_equal chart_builder.object_id, chart_builder2.object_id

    assert_equal(
      [{ commit: benchmark_run.initiator.sha1 }, { commit: other_benchmark_run.initiator.sha1 }],
      chart_builder.categories
    )
    assert_equal(
      [
        { name: "some_time", data: [benchmark_run.result['some_time'].to_f, other_benchmark_run.result['some_time'].to_f] },
        { name: "some_other_time", data: [benchmark_run.result['some_other_time'].to_f, other_benchmark_run.result['some_other_time'].to_f] }
      ],
      chart_builder.columns
    )
  end

  test "#build_columns with comparing_runs" do
    rails_repo = create(:repo)
    sequel_repo = create(:repo)

    rails_benchmark = create(:benchmark_type)
    sequel_benchmark = create(:benchmark_type)

    rails_commit = create(:commit)
    sequel_commit1 = create(:commit, created_at: 10.days.ago)
    sequel_commit2 = create(:commit, created_at: 4.days.ago)

    benchmark_type = create(:benchmark_result_type)

    rails_run = create(:benchmark_run, benchmark_type: rails_benchmark, initiator: rails_commit, benchmark_result_type: benchmark_type, result: { 'some_time' => 5 })
    sequel_run1 = create(:benchmark_run, benchmark_type: sequel_benchmark, initiator: sequel_commit1, benchmark_result_type: benchmark_type, result: { 'some_time' => 5 })
    sequel_run2 = create(:benchmark_run, benchmark_type: sequel_benchmark, initiator: sequel_commit2, benchmark_result_type: benchmark_type, result: { 'some_time' => 5 })

    chart_builder = ChartBuilder.new([rails_run], benchmark_type, [sequel_run1, sequel_run2])

    chart_builder.build_columns do |benchmark_run|
      { commit: benchmark_run.initiator.sha1 }
    end

    assert_equal(
      [
        { commit: sequel_run1.initiator.sha1 },
        { commit: sequel_run2.initiator.sha1 },
        { commit: rails_run.initiator.sha1 }
      ],
      chart_builder.categories
    )

    assert_equal(
      [
        {
          name: "some_time_#{sequel_run1.benchmark_type.category}",
          data: [
            [{ commit: sequel_run1.initiator.sha1 }, 5.0],
            [{ commit: sequel_run2.initiator.sha1 }, 5.0]
          ]
        },
        {
          name: "some_time_#{rails_run.benchmark_type.category}",
          data: [[{ commit: rails_run.initiator.sha1 }, 5.0]]
        }
      ],
      chart_builder.columns
    )
  end

  test "#construct_from_cache" do
    cache_read = {
      datasets: [{ name: "benchmark1", data: [1.1, 1.2] }],
      versions: [{ version: 1, environment: "ruby2.2" }, { version: 2, environment: "ruby2.3" }]
    }

    benchmark_result_type = { measurement: "Execution time", unit: "Seconds" }

    chart_builder = ChartBuilder.construct_from_cache(cache_read, benchmark_result_type)

    assert_instance_of ChartBuilder, chart_builder
    assert_equal chart_builder.categories, cache_read[:versions]
    assert_equal chart_builder.columns, cache_read[:datasets]
    assert_equal chart_builder.benchmark_result_type, benchmark_result_type
  end

  test "#build_columns and construct_from_cache give the same result" do
    benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    other_benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    chart_builder = ChartBuilder.new([benchmark_run, other_benchmark_run], benchmark_run.benchmark_result_type)

    chart_builder.build_columns do |benchmark_run|
      { commit: benchmark_run.initiator.sha1 }
    end

    cache_read = {
      datasets: chart_builder.columns,
      versions: chart_builder.categories
    }
    benchmark_result_type = benchmark_run.benchmark_result_type

    chart_builder2 = ChartBuilder.construct_from_cache(cache_read, benchmark_result_type)

    assert_equal chart_builder.columns, chart_builder2.columns
    assert_equal chart_builder.categories, chart_builder2.categories
    assert_equal chart_builder.benchmark_result_type, chart_builder2.benchmark_result_type
  end
end
