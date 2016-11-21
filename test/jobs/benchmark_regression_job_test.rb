require 'test_helper'

class BenchmarkRegressionJobTest < ActiveJob::TestCase
  setup do
    @array = [323, 11, 555, 666, 234, 21, 666, 343, 1, 2]
    benchmark_result_type = create(:benchmark_result_type)
    benchmark_type = create(:benchmark_type)
    repo = create(:repo)
    10.times do
      commit = create(:commit, repo: repo)
      @benchmark_run = create(:commit_benchmark_run,
                              benchmark_result_type: benchmark_result_type,
                              benchmark_type: benchmark_type,
                              initiator: commit)
    end
  end

  test "create issue for benchmark regression" do
    VCR.use_cassette('benchmark_regression') do
      response = BenchmarkRegressionJob.new.create_issue(@benchmark_run, @benchmark_run.result.keys[0], 4.0)
      assert_equal "201", response.code
    end
  end

  test "calculates average" do
    assert_equal 282.2, BenchmarkRegressionJob.new.average(@array)
  end

  test "calculates standard_deviation" do
    assert_equal 274.08, BenchmarkRegressionJob.new.standard_deviation(@array, BenchmarkRegressionJob.new.average(@array)).round(2)
  end

  test "check for similar issues" do
    travel_to "2016-07-03 13:50:41 +0530" do
      VCR.use_cassette('similar_issues') do
        assert BenchmarkRegressionJob.new.check_equal(@benchmark_run, @benchmark_run.result.keys[0], 4.0)
      end
    end
  end
end
