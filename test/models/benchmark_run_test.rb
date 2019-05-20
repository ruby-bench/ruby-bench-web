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
    benchmark_result_type = create(:benchmark_result_type)
    benchmark_type = create(:benchmark_type)
    commit = create(:commit)
    later_commit = create(:commit, created_at: Time.zone.now + 1.day)

    benchmark_run = create(:commit_benchmark_run,
      benchmark_result_type: benchmark_result_type,
      benchmark_type: benchmark_type,
      initiator: commit
    )

    benchmark_run2 = create(:commit_benchmark_run,
      benchmark_result_type: benchmark_result_type,
      benchmark_type: benchmark_type,
      initiator: later_commit
    )

    assert_equal(
      benchmark_run2,
      BenchmarkRun.latest_commit_benchmark_run(benchmark_type, benchmark_result_type)
    )
  end

  test '.fetch_release_benchmark_runs' do
    script_url = 'https://raw.githubusercontent.com/org/repo/master/script/bench.rb'

    ruby = create(:repo, name: 'ruby')
    rails = create(:repo, name: 'rails')

    ruby_release = create(:release, repo: ruby, version: '2.6.2')
    rails_release = create(:release, repo: rails, version: '6.0.0')

    ruby_benchmark_type = create(:benchmark_type, category: 'discourse_home', repo: ruby, script_url: script_url)
    rails_benchmark_type = create(:benchmark_type, category: 'discourse_home', repo: rails, script_url: script_url)

    benchmark_result_type = create(:benchmark_result_type)
    ruby_benchmark_run = create(:release_benchmark_run,
      benchmark_result_type: benchmark_result_type,
      benchmark_type: ruby_benchmark_type,
      initiator: ruby_release
    )
    rails_benchmark_run = create(:release_benchmark_run,
      benchmark_result_type: benchmark_result_type,
      benchmark_type: rails_benchmark_type,
      initiator: rails_release
    )
    ruby_result = BenchmarkRun.fetch_release_benchmark_runs(ruby_benchmark_type, benchmark_result_type)
    assert_equal(1, ruby_result.size)
    assert_equal(ruby_benchmark_run.id, ruby_result.first.id)

    rails_result = BenchmarkRun.fetch_release_benchmark_runs(rails_benchmark_type, benchmark_result_type)
    assert_equal(1, rails_result.size)
    assert_equal(rails_benchmark_run.id, rails_result.first.id)
  end
end
