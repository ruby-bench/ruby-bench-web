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
      [
        [
          ["Commit: #{benchmark_run.initiator.sha1}", "Commit: #{other_benchmark_run.initiator.sha1}"],
          "seconds",
          "#{benchmark_run.script_url}",
          "#{benchmark_run.category}",
          [benchmark_run.result['some_time'].to_f, other_benchmark_run.result['some_time'].to_f],
          [benchmark_run.result['some_other_time'].to_f, other_benchmark_run.result['some_other_time'].to_f]
        ]
      ],
      chart_columns
    )
  end
end
