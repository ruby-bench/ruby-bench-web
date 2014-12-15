require 'test_helper'

class BenchmarkRunsTest < ActionDispatch::IntegrationTest
  def test_create_benchmark_run
    commit = commits(:commit)
    repo = repos(:repo)
    organization = organizations(:organization)

    post('/benchmark_runs', {
      benchmark_run: {
        category: 'allocated_objects',
        result: { fast: 'slow' },
        environment: 'ruby-2.1.5',
        unit: 'seconds',
        script_url: 'http://something.com'
      },
      commit_hash: commit.sha1,
      repo: repo.name,
      organization: organization.name
    })

    # FIXME: This is acting like a smoke test.
    benchmark_run = BenchmarkRun.last
    assert_equal 'allocated_objects', benchmark_run.category
    assert_equal commit, benchmark_run.commit
    assert_equal repo, benchmark_run.commit.repo
    assert_equal organization, benchmark_run.commit.repo.organization
  end
end
