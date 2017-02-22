require 'test_helper'

class JSONGeneratorTest < ActiveSupport::TestCase
  include JSONGenerator

  testcases = JSON.parse(file_fixture("json_generator_tests.json").read, symbolize_names: true)

  test "JSON generation works when there is one dataset in chart" do
    testcase = testcases[:test_one_dataset_in_chart]
    chart_cache = testcase[:chart]
    benchmark_result_type = testcase[:benchmark_result_type]

    chart_builder = ChartBuilder.new([], benchmark_result_type).construct_from_cache(chart_cache)

    assert_equal(
      generate_json([chart_builder], { result_type: "ao_bench" }).to_json,
      testcase[:expected].to_json
    )
  end

  test "JSON generation works when there are two datasets in chart" do
    testcase = testcases[:test_two_datasets_in_chart]
    chart_cache = testcase[:chart]
    benchmark_result_type = testcase[:benchmark_result_type]

    chart_builder = ChartBuilder.new([], benchmark_result_type).construct_from_cache(chart_cache)

    assert_equal(
      generate_json([chart_builder], { result_type: "ao_bench" }).to_json,
      testcase[:expected].to_json
    )
  end
end
