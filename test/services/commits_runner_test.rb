require 'test_helper'

class CommitsRunnerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @repo = create(:repo, name: 'rails')
  end

  test '#run' do
    commits = [
      {
        sha: '12345',
        message: 'My beautiful commit message',
        repo: @repo,
        author_name: 'bmarkons',
        url: 'https://github.com/commit',
        created_at: 12345
      }
    ]

    CommitsRunner.run(commits)

    expect_created(commits)
    assert_enqueued_jobs(commits.count)
  end

  def expect_created(commits_hashes)
    commits_hashes.each do |hash|
      commit = Commit.find_by!(sha1: hash[:sha])

      assert_equal hash[:sha], commit.sha1
      assert_equal hash[:message], commit.message
      assert_equal hash[:repo].id, commit.repo.id
      assert_equal hash[:repo].name, commit.repo.name
      assert_equal hash[:url], commit.url
      refute_equal hash[:created_at], commit.created_at
    end
  end
end
