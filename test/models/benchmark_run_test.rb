require 'test_helper'

class BenchmarkRunTest < ActiveSupport::TestCase
  test '.sort_by_initiator_version' do
    releases = [
      create(:release, version: 'githubruby', benchmark_runs: [create(:release_benchmark_run)]),
      create(:release, version: '1.2.1', benchmark_runs: [create(:release_benchmark_run)]),
      create(:release, version: '1.1.10', benchmark_runs: [create(:release_benchmark_run)]),
      create(:release, version: '1.1.1', benchmark_runs: [create(:release_benchmark_run)])
    ]

    benchmark_runs = releases.map(&:benchmark_runs).flatten!

    assert_equal(
      %w{1.1.1 1.1.10 1.2.1 githubruby},
      BenchmarkRun.sort_by_initiator_version(benchmark_runs).map!(&:initiator).map(&:version)
    )
  end

  test '.latest_commit_benchmark_run' do
    result_type = create(:result_type)
    benchmark = create(:benchmark)
    commit = create(:commit)
    later_commit = create(:commit, created_at: Time.zone.now + 1.day)

    benchmark_run = create(:commit_benchmark_run,
      result_type: result_type,
      benchmark: benchmark,
      initiator: commit
    )

    benchmark_run2 = create(:commit_benchmark_run,
      result_type: result_type,
      benchmark: benchmark,
      initiator: later_commit
    )

    assert_equal(
      benchmark_run2,
      BenchmarkRun.latest_commit_benchmark_run(benchmark, result_type)
    )
  end
end
