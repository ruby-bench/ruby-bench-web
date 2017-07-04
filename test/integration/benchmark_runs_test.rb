require 'test_helper'

class BenchmarkRunsTest < ActionDispatch::IntegrationTest
  def test_create_commit_benchmark_run
    @repo = create(:repo)
    commit = create(:commit, repo: @repo)

    post_results(
      commit_hash: commit.sha1,
      repo: @repo.name,
      organization: @repo.organization.name
    )

    assert_results(commit)
  end

  test 'create release benchmark_run' do
    @repo = create(:repo)
    release = create(:release, repo: @repo)

    post_results(
      version: release.version,
      repo: @repo.name,
      organization: @repo.organization.name
    )

    assert_results(release)
  end

  test 'create release benchmark_run when there is no past release' do
    @repo = create(:repo)

    post_results(
      version: '10.0.0',
      repo: @repo.name,
      organization: @repo.organization.name
    )

    assert_results(Release.last)
  end

  test 'repeated benchmark_runs are replaced' do
    @repo = create(:repo)
    release = create(:release, repo: @repo)

    post_results(
      version: release.version,
      repo: @repo.name,
      organization: @repo.organization.name
    )

    assert_results(release)
    initial_count = release.benchmark_runs.count
    initial_benchmark_run = release.benchmark_runs.first
    expected_result = { 'fast' => 'fast', 'slow' => 'slow' }

    post_results(
      {
        version: release.version,
        repo: @repo.name,
        organization: @repo.organization.name
      },
              result: expected_result
    )

    assert_results(release)
    final_benchmark_run = BenchmarkRun.first
    assert_equal expected_result, final_benchmark_run.result
    assert_equal initial_benchmark_run.id, final_benchmark_run.id
    assert_equal initial_count, release.benchmark_runs.count
  end

  test 'old benchmark_runs are invalidated' do
    @repo = create(:repo)
    release = create(:release, repo: @repo)
    bm_type = create(:benchmark, repo: @repo)

    bm_run = create(:release_benchmark_run,
      benchmark: bm_type, validity: true, initiator: release
    )

    post_results(version: release.version,
      repo: @repo.name,
      organization: @repo.organization.name,
      benchmark: {
        label: bm_type.label,
        script_url: bm_type.script_url,
        digest: 'digestchanged'
      })

    assert_not bm_run.reload.validity
  end

  private

  def assert_results(commit_or_release)
    benchmark_run = BenchmarkRun.first
    benchmark = benchmark_run.benchmark
    assert_equal 'allocated_objects', benchmark.label
    assert_equal 'http://something.com', benchmark.script_url
    assert_equal 'thisisadigest', benchmark.digest
    assert_equal commit_or_release, benchmark_run.initiator
    assert_equal @repo, benchmark_run.initiator.repo
    assert_equal @repo.organization, benchmark_run.initiator.repo.organization
  end

  def post_results(params = {}, attribute_params = {})
    post('/benchmark_runs',
      params: {
        result_type: {
          name: 'Execution time',
          unit: 'Seconds'
        },
        benchmark: {
          label: 'allocated_objects',
          script_url: 'http://something.com',
          digest: 'thisisadigest'
        },
        benchmark_run: {
          result: { fast: 'slow' },
          environment: 'ruby-2.1.5'
        }.merge(attribute_params),
      }.merge(params),
      headers: {
        'HTTP_AUTHORIZATION' =>
          ActionController::HttpAuthentication::Basic.encode_credentials(
            Rails.application.secrets.api_name,
            Rails.application.secrets.api_password
          )
      }
    )
  end
end
