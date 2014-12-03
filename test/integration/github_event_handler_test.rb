require 'test_helper'

class GithubEventHandlerTest < ActionDispatch::IntegrationTest
  setup do
    # FIXME: Called to remove fixtures. Should probably update the test for
    # better assertions.
    Repo.destroy_all
    Commit.destroy_all
  end

  test "#handle for single commits pushed" do
    RemoteServerJob.expects(:perform_later).once

    post_to_handler({
      'head_commit' => {
        'id' => '12345',
        'message' => 'Fix something',
        'url' => 'http://github.com/rails/commit/12345',
        'timestamp' => '2014-11-20T15:45:15-08:00'
      },
      'repository' => {
        'name' => 'rails',
        html_url: 'https://github.com/tgxworld/rails'
      }
    })

    assert_equal 'rails', Repo.first.name
    assert_equal 'http://github.com/rails/commit/12345', Commit.first.url
    assert_equal Repo.first, Commit.first.repo
  end

  test "#handle for multiple commits pushed" do
    RemoteServerJob.expects(:perform_later).twice

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
          'name' => 'rails',
          html_url: 'https://github.com/tgxworld/rails'
        }
    })

    assert_equal 'rails', Repo.first.name
    assert_equal 2, Commit.count
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
          'name' => 'rails',
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
