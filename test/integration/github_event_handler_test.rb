require 'test_helper'

class GithubEventHandlerTest < ActionDispatch::IntegrationTest
  setup do
    # FIXME: Called to remove fixtures. Should probably update the test for
    # better assertions.
    Repo.destroy_all
    Commit.destroy_all
    Organization.destroy_all
  end

  test "#handle for single commits pushed" do
    # FIXME: I can't figure out how I can test ActiveSupport::Notifications.instrument
    # was called. We need to test for it.
    post_to_handler({
      'head_commit' => {
        'id' => '12345',
        'message' => 'Fix something',
        'url' => 'http://github.com/rails/commit/12345',
        'timestamp' => '2014-11-20T15:45:15-08:00'
      },
      'repository' => {
        'full_name' => 'tgxworld/rails',
        html_url: 'https://github.com/tgxworld/rails'
      }
    })

    organization = Organization.first
    repo = Repo.first
    commit = Commit.first

    assert_equal 'tgxworld', organization.name
    assert_equal 'rails', repo.name
    assert_equal organization, repo.organization
    assert_equal 'http://github.com/rails/commit/12345', commit.url
    assert_equal repo, commit.repo
  end

  test "#handle for multiple commits pushed" do
    # FIXME: I can't figure out how I can test ActiveSupport::Notifications.instrument
    # was called. We need to test for it.

    post_to_handler({
      'commits' =>
        [
          {
            'id' => '12345',
            'message' => 'Fix something',
            'url' => 'http://github.com/rails/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00'
          },
          {
            'id' => '12346',
            'message' => 'Fix something',
            'url' => 'http://github.com/rails/commit/12346',
            'timestamp' => '2014-11-20T15:45:15-08:00'
          }
        ],
        'repository' => {
          'full_name' => 'tgxworld/rails',
          html_url: 'https://github.com/tgxworld/rails'
        }
    })

    organization = Organization.first
    repo = Repo.first
    commit = Commit.first

    assert_equal 'tgxworld', organization.name
    assert_equal 'rails', repo.name
    assert_equal organization, repo.organization
    assert_equal 2, Commit.count

    Commit.all.each do |commit|
      assert_equal repo, commit.repo
    end
  end

  test "Commits are not created for merge and ci skip commits" do
    initial = Commit.count

    post_to_handler({
      'commits' =>
        [
          {
            'id' => '12345',
            'message' => Commit::MERGE_COMMIT_MESSAGE,
            'url' => 'http://github.com/rails/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00'
          },
          {
            'id' => '12346',
            'message' => Commit::CI_SKIP_COMMIT_MESSAGE,
            'url' => 'http://github.com/rails/commit/12346',
            'timestamp' => '2014-11-20T15:45:15-08:00'
          }
        ],
        'repository' => {
          'full_name' => 'tgxworld/rails',
          html_url: 'https://github.com/tgxworld/rails'
        }
    })

    assert_equal initial, Commit.count
  end

  private

  def post_to_handler(parameters)
    post(
      '/github_event_handler', parameters,
      { "#{GithubEventHandler::HEADER}" => "#{GithubEventHandler::PUSH}" }
    )
  end
end
