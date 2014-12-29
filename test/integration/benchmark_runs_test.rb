require 'test_helper'

class BenchmarkRunsTest < ActionDispatch::IntegrationTest
  setup do
    @repo = repos(:repo)
    @organization = organizations(:organization)
  end

  def test_create_commit_benchmark_run
    commit = commits(:commit)

    post_results(
      commit_hash: commit.sha1,
      repo: @repo.name,
      organization: @organization.name
    )

    assert_results(commit)
  end

  test "create release benchmark_run" do
    release = releases(:release)

    post_results(
      ruby_version: release.version,
      repo: @repo.name,
      organization: @organization.name
    )

    assert_results(release)
  end

  test "create release benchmark_run when there is no past release" do
    post_results(
      ruby_version: '10.0.0',
      repo: @repo.name,
      organization: @organization.name
    )

    assert_results(Release.last)
  end

  private

  def assert_results(commit_or_release)
    benchmark_run = BenchmarkRun.last
    assert_equal 'allocated_objects', benchmark_run.category
    assert_equal commit_or_release, benchmark_run.initiator
    assert_equal @repo, benchmark_run.initiator.repo
    assert_equal @organization, benchmark_run.initiator.repo.organization
  end

  def post_results(params = {})
    post('/benchmark_runs',
      {
        benchmark_run: {
          category: 'allocated_objects',
          result: { fast: 'slow' },
          environment: 'ruby-2.1.5',
          unit: 'seconds',
          script_url: 'http://something.com'
        },
      }.merge(params),
      {
        'HTTP_AUTHORIZATION' =>
          ActionController::HttpAuthentication::Basic.encode_credentials(
            Rails.application.secrets.api_name,
            Rails.application.secrets.api_password
          )
      }
    )
  end
end
