require 'test_helper'

class BenchmarkRunsTest < ActionDispatch::IntegrationTest
  def test_create_commit_benchmark_run
    @repo = repos(:rails)
    commit = commits(:rails_commit)

    post_results(
      commit_hash: commit.sha1,
      repo: @repo.name,
      organization: @repo.organization.name
    )

    assert_results(commit)
  end

  test "create release benchmark_run" do
    @repo = repos(:ruby)
    release = releases(:ruby_2_2_0)

    post_results(
      ruby_version: release.version,
      repo: @repo.name,
      organization: @repo.organization.name
    )

    assert_results(release)
  end

  test "create release benchmark_run when there is no past release" do
    @repo = repos(:rails)

    post_results(
      ruby_version: '10.0.0',
      repo: @repo.name,
      organization: @repo.organization.name
    )

    assert_results(Release.last)
  end

  # Remove this once Github hook is actually coming from the original Ruby
  # repo.
  test "tgxworld organization is mapped to ruby" do
    @repo = repos(:ruby)
    release = releases(:ruby_2_2_0)

    post_results(
      ruby_version: release.version,
      repo: @repo.name,
      organization: 'tgxworld'
    )

    assert_results(release)
  end

  private

  def assert_results(commit_or_release)
    benchmark_run = BenchmarkRun.last
    assert_equal 'allocated_objects', benchmark_run.benchmark_type.category
    assert_equal commit_or_release, benchmark_run.initiator
    assert_equal @repo, benchmark_run.initiator.repo
    assert_equal @repo.organization, benchmark_run.initiator.repo.organization
  end

  def post_results(params = {})
    post('/benchmark_runs',
      {
        benchmark_type: {
          category: 'allocated_objects',
          unit: 'seconds',
          script_url: 'http://something.com'
        },
        benchmark_run: {
          result: { fast: 'slow' },
          environment: 'ruby-2.1.5'
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
