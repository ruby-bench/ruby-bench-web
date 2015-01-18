require 'test_helper'

class ChartBuilderTest < ActiveSupport::TestCase
  test "#build_columns" do
    benchmark_run = benchmark_runs(:array_count_run)
    other_benchmark_run = benchmark_runs(:array_iterations_run2)

    chart_builder = ChartBuilder.new(
      [benchmark_run, other_benchmark_run],
    )

    chart_columns = chart_builder.build_columns do |benchmark_run|
      "Commit: #{benchmark_run.initiator.sha1}"
    end

    assert_equal(
      {
        category: "#{benchmark_run.benchmark_type.category}",
        unit: "#{benchmark_run.benchmark_type.unit}",
        script_url: "#{benchmark_run.benchmark_type.script_url}",
        categories: ["Commit: #{benchmark_run.initiator.sha1}", "Commit: #{other_benchmark_run.initiator.sha1}"],
        columns: [
          { name: "some_time", data: [benchmark_run.result['some_time'].to_f, other_benchmark_run.result['some_time'].to_f] },
          { name: "some_other_time", data: [benchmark_run.result['some_other_time'].to_f, other_benchmark_run.result['some_other_time'].to_f] }
        ].to_json
      },
      chart_columns
    )
  end
end
