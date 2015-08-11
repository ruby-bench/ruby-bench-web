require 'test_helper'

class BenchmarkTypeTest < ActiveSupport::TestCase
  test "#github_url" do
    benchmark_type = create(:benchmark_type)
    assert_equal(
      benchmark_type.github_url,
      'https://github.com/ruby-bench/ruby-bench-suite/blob/master/ruby/benchmarks/bm_app_answer.rb'
    )
  end

  test "updating digest should render benchmark_runs invalid" do
    benchmark_type = create(:benchmark_type, digest: 'abcde')
    bm_run = create(:commit_benchmark_run, benchmark_type: benchmark_type)

    benchmark_type.update_attributes(digest: 'test')

    assert_not bm_run.reload.validity

    # Remove once digest cannot be null
    benchmark_type = create(:benchmark_type, digest: nil)
    bm_run = create(:commit_benchmark_run, benchmark_type: benchmark_type, validity: true)

    benchmark_type.update_attributes(digest: 'haha')

    assert bm_run.reload.validity
  end
end
