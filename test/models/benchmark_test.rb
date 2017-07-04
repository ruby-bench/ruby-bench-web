require 'test_helper'

class BenchmarkTypeTest < ActiveSupport::TestCase
  test '#github_url' do
    benchmark = create(:benchmark)
    assert_equal(
      benchmark.github_url,
      'https://github.com/ruby-bench/ruby-bench-suite/blob/master/ruby/benchmarks/bm_app_answer.rb'
    )
  end

  test 'updating digest should render benchmark_runs invalid' do
    benchmark = create(:benchmark, digest: 'abcde')
    bm_run = create(:commit_benchmark_run, benchmark: benchmark)

    benchmark.update_attributes(digest: 'test')

    assert_not bm_run.reload.validity

    # Remove once digest cannot be null
    benchmark = create(:benchmark, digest: nil)
    bm_run = create(:commit_benchmark_run, benchmark: benchmark, validity: true)

    benchmark.update_attributes(digest: 'haha')

    assert bm_run.reload.validity
  end
end
