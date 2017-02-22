require 'test_helper'

class ChartBuilderTest < ActiveSupport::TestCase
  test "#build_columns" do
    benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    other_benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    chart_builder = ChartBuilder.new([benchmark_run, other_benchmark_run], benchmark_run.benchmark_result_type)

    chart_data = chart_builder.build_columns do |benchmark_run|
      { commit: benchmark_run.initiator.sha1 }
    end

    assert_equal(
      ["Commit: #{benchmark_run.initiator.sha1}", "Commit: #{other_benchmark_run.initiator.sha1}"].to_json,
      chart_data[:categories]
    )
    assert_equal(
      [
        { name: "some_time", data: [benchmark_run.result['some_time'].to_f, other_benchmark_run.result['some_time'].to_f] },
        { name: "some_other_time", data: [benchmark_run.result['some_other_time'].to_f, other_benchmark_run.result['some_other_time'].to_f] }
      ].to_json,
      chart_data[:columns]
    )
  end
end
