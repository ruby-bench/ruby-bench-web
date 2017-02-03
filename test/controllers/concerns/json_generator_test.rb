require 'test_helper'

class JSONGeneratorTest < ActiveSupport::TestCase
	include JSONGenerator

	testcases = JSON.parse(file_fixture("json_generator_tests.json").read, symbolize_names: true)

	test "JSON generation works when there is one dataset in chart" do
		testcase = testcases[:test_one_dataset_in_chart]
		charts = testcase[:charts]
		versions = testcase[:versions]

		assert_equal(
			generate_json(charts, versions, { result_type: "ao_bench" }).to_json,
			testcase[:expected].to_json
		)
	end

	test "JSON generation works when there are two datasets in chart" do
		testcase = testcases[:test_two_datasets_in_chart]
		charts = testcase[:charts]
		versions = testcase[:versions]

		assert_equal(
			generate_json(charts, versions, { result_type: "ao_bench" }).to_json,
			testcase[:expected].to_json
		)
	end
end