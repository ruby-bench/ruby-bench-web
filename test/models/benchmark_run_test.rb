require 'test_helper'

class BenchmarkRunTest < ActiveSupport::TestCase
  test ".initiators scope" do
    commit = commits(:ruby_commit)
    other_commit = commits(:ruby_commit2)

    assert_equal(
      [
        benchmark_runs(:benchmark_run), benchmark_runs(:benchmark_run2),
        benchmark_runs(:benchmark_run5)
      ].sort,
      BenchmarkRun.initiators([commit.id, other_commit.id], 'Commit').sort
    )
  end
end
