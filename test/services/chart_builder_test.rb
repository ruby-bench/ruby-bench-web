require 'test_helper'

class ChartBuilderTest < ActiveSupport::TestCase
  test "#build_columns" do
    benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    other_benchmark_run = create(:commit_benchmark_run, result: { 'some_time' => 5, 'some_other_time' => 5 })
    chart_builder = ChartBuilder.new([benchmark_run, other_benchmark_run])

    chart_columns = chart_builder.build_columns do |benchmark_run|
      "Commit: #{benchmark_run.initiator.sha1}"
    end

    assert_equal(
      {
        categories: ["Commit: #{benchmark_run.initiator.sha1}", "Commit: #{other_benchmark_run.initiator.sha1}"].to_json,
        columns: [
          { name: "some_time", data: [benchmark_run.result['some_time'].to_f, other_benchmark_run.result['some_time'].to_f] },
          { name: "some_other_time", data: [benchmark_run.result['some_other_time'].to_f, other_benchmark_run.result['some_other_time'].to_f] }
        ].to_json
      },
      chart_columns
    )
  end
end
