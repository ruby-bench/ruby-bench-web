class BenchmarkRunsTest < ActionDispatch::IntegrationTest
  def test_create_benchmark_run
    commit = commits(:commit)

    post('/benchmark_runs', {
      benchmark_run: {
        category: 'allocated_objects',
        result: { fast: 'slow' },
        environment: 'ruby-2.1.5',
      },
      commit_hash: commit.sha1
    })

    benchmark_run = BenchmarkRun.first
    assert_equal 'allocated_objects', benchmark_run.category
    assert_equal commit, benchmark_run.commit
  end
end
