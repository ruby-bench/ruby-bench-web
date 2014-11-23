require 'test_helper'

class GithubEventHandlerTest < ActionDispatch::IntegrationTest
  test "#handle for single commits pushed" do
    RemoteServerJob.expects(:perform_later).once

    post_to_handler({
      'head_commit' => {
        'id' => '12345',
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
            'url' => 'http://github.com/rails/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00'
          },
          {
            'id' => '12346',
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
    assert_equal 2, Commit.all.count
    assert_equal '12345', Commit.first.sha1
    assert_equal '12346', Commit.last.sha1
  end

  private

  def post_to_handler(parameters)
    post(
      '/github_event_handler', parameters,
      { "#{GithubEventHandler::HEADER}" => "#{GithubEventHandler::PUSH}" }
    )
  end
end
