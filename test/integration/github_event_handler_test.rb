require 'test_helper'

class GithubEventHandlerTest < ActionDispatch::IntegrationTest
  test "#handle for single commits pushed" do
    BenchmarkPool.expects(:enqueue).with('ruby', '12345')

    post_to_handler({
      'head_commit' => {
        'id' => '12345',
        'message' => 'Fix something',
        'url' => 'http://github.com/ruby/commit/12345',
        'timestamp' => '2014-11-20T15:45:15-08:00',
        'author' => {
          'name' => 'Alan'
        }
      },
      'repository' => {
        'full_name' => 'ruby/ruby',
        html_url: 'https://github.com/ruby/ruby'
      }
    })

    organization = Organization.last
    repo = Repo.last
    commit = Commit.last

    assert_equal 'ruby', organization.name
    assert_equal 'ruby', repo.name
    assert_equal organization, repo.organization
    assert_equal 'http://github.com/ruby/commit/12345', commit.url
    assert_equal repo, commit.repo
  end

  test "#handle for multiple commits pushed" do
    BenchmarkPool.expects(:enqueue).with('ruby', '12345')
    BenchmarkPool.expects(:enqueue).with('ruby', '12346')

    post_to_handler({
      'commits' =>
        [
          {
            'id' => '12345',
            'message' => 'Fix something',
            'url' => 'http://github.com/ruby/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00',
            'author' => {
              'name' => 'Alan'
            }
          },
          {
            'id' => '12346',
            'message' => 'Fix something',
            'url' => 'http://github.com/ruby/commit/12346',
            'timestamp' => '2014-11-20T15:45:15-08:00',
            'author' => {
              'name' => 'Alan'
            }
          },
        ],
        'repository' => {
          'full_name' => 'ruby/ruby',
          html_url: 'https://github.com/ruby/ruby'
        }
    })

    organization = Organization.last
    repo = Repo.last
    commit = Commit.last

    assert_equal 'ruby', organization.name
    assert_equal 'ruby', repo.name
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
            'message' => CommitReviewer::MERGE_COMMIT_MESSAGE,
            'url' => 'http://github.com/ruby/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00',
            'author' => {
              'name' => 'Alan'
            }
          },
          {
            'id' => '12346',
            'message' => CommitReviewer::CI_SKIP_COMMIT_MESSAGE,
            'url' => 'http://github.com/ruby/commit/12346',
            'timestamp' => '2014-11-20T15:45:15-08:00',
            'author' => {
              'name' => 'Alan'
            }
          },
          {
            'id' => '13456',
            'message' => 'ok',
            'author' => {
              'name' => 'svn'
            },
            'url' => 'http://github.com/ruby/commit/12346',
            'timestamp' => '2014-11-20T15:45:15-08:00',
          }
        ],
        'repository' => {
          'full_name' => 'ruby/ruby',
          html_url: 'https://github.com/ruby/ruby'
        }
    })

    assert_equal initial, Commit.count
  end


  # Remove this once Github hook is actually coming from the original Ruby
  # repo.
  test "tgxworld organization is mapped as ruby" do
    post_to_handler({
      'commits' =>
        [
          {
            'id' => '12345',
            'message' => 'Fix something',
            'url' => 'http://github.com/ruby/ruby/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00',
            'author' => {
              'name' => 'Alan'
            }
          }
        ],
        'repository' => {
          'full_name' => 'tgxworld/ruby',
          html_url: 'https://github.com/tgxworld/ruby'
        }
    })

    organization = Organization.last
    repo = Repo.last
    commit = Commit.last

    assert_equal 'ruby', organization.name
    assert_equal 'ruby', repo.name
    assert_equal organization, repo.organization
    assert_equal 'http://github.com/ruby/ruby/commit/12345', commit.url
    assert_equal repo, commit.repo
  end

  # Remove this once Github hook is actually coming from the original Rails
  # repo.
  test "tgxworld organization is mapped as rails" do
    post_to_handler({
      'commits' =>
        [
          {
            'id' => '12345',
            'message' => 'Fix something',
            'url' => 'http://github.com/rails/rails/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00',
            'author' => {
              'name' => 'Alan'
            }
          }
        ],
        'repository' => {
          'full_name' => 'tgxworld/rails',
          html_url: 'https://github.com/tgxworld/rails'
        }
    })

    organization = Organization.last
    repo = Repo.last
    commit = Commit.last

    assert_equal 'rails', organization.name
    assert_equal 'rails', repo.name
    assert_equal organization, repo.organization
    assert_equal 'http://github.com/rails/rails/commit/12345', commit.url
    assert_equal repo, commit.repo
  end

  # Remove this once Github hook is actually coming from the original Sequel
  # repo.
  test "tgxworld organization is mapped as sequel" do
    post_to_handler({
      'commits' =>
        [
          {
            'id' => '12345',
            'message' => 'Fix something',
            'url' => 'http://github.com/jeremyevans/sequel/commit/12345',
            'timestamp' => '2014-11-20T15:45:15-08:00',
            'author' => {
              'name' => 'Alan'
            }
          }
        ],
        'repository' => {
          'full_name' => 'tgxworld/sequel',
          html_url: 'https://github.com/tgxworld/sequel'
        }
    })

    organization = Organization.first
    repo = Repo.first
    commit = Commit.first

    assert_equal 'jeremyevans', organization.name
    assert_equal 'sequel', repo.name
    assert_equal organization, repo.organization
    assert_equal 'http://github.com/jeremyevans/sequel/commit/12345', commit.url
    assert_equal repo, commit.repo
  end

  private

  def post_to_handler(parameters)
    post(
      '/github_event_handler', params: parameters,
      headers: {
        "#{GithubEventHandler::HEADER}" => "#{GithubEventHandler::PUSH}",
        'HTTP_AUTHORIZATION' =>
          ActionController::HttpAuthentication::Basic.encode_credentials(
            Rails.application.secrets.api_name,
            Rails.application.secrets.api_password
          )
      }
    )
  end
end
