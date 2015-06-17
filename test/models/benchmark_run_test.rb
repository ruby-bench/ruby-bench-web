require 'test_helper'

class BenchmarkRunTest < ActiveSupport::TestCase
  test ".sort_by_initiator_version" do
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
end
