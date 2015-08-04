require 'test_helper'

class BenchmarkTypeTest < ActiveSupport::TestCase
  test "#github_url" do
    benchmark_type = create(:benchmark_type)
    assert_equal(
      benchmark_type.github_url,
      'https://github.com/ruby-bench/ruby-bench-suite/blob/master/ruby/benchmarks/bm_app_answer.rb'
    )
  end
end
