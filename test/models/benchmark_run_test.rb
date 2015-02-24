require 'test_helper'

class BenchmarkRunTest < ActiveSupport::TestCase
  test ".initiators scope" do
    commit = commits(:ruby_commit)
    other_commit = commits(:ruby_commit2)

    assert_equal(
      [
        benchmark_runs(:array_count_run),
        benchmark_runs(:array_count_run3),
        benchmark_runs(:array_iterations_run2),
        benchmark_runs(:array_iterations_memory_run2)
      ].sort,
      BenchmarkRun.initiators([commit.id, other_commit.id], 'Commit').sort
    )
  end
end
