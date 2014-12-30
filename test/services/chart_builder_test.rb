require 'test_helper'

class ChartBuilderTest < ActiveSupport::TestCase
  test "#build_columns" do
    benchmark_run = benchmark_runs(:benchmark_run)
    other_benchmark_run = benchmark_runs(:benchmark_run5)

    chart_builder = ChartBuilder.new(
      [benchmark_run, other_benchmark_run],
    )

    chart_columns = chart_builder.build_columns do |benchmark_run|
      "Commit: #{benchmark_run.initiator.sha1}"
    end

    assert_equal(
      {
        category: "#{benchmark_run.category}",
        unit: "#{benchmark_run.unit}",
        script_url: "#{benchmark_run.script_url}",
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
