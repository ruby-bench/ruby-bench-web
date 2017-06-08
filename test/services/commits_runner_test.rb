require 'test_helper'

class CommitsRunnerTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repo)
    BenchmarkPool.stubs(:enqueue)
  end

  test '#run' do
    commits = [
      {
        sha: '12345',
        message: 'My beautiful commit message',
        repo: {
          id: @repo.id,
          name: @repo.name
        },
        author: {
          name: 'bmarkons'
        },
        url: 'https://github.com/commit',
        created_at: 12345
      }
    ]

    CommitsRunner.run(commits)

    expect_created(commits)
  end

  def expect_created(commits_hashes)
    commits_hashes.each do |hash|
      commit = Commit.find_by!(sha1: hash[:sha])

      assert_equal commit.sha1, hash[:sha]
      assert_equal commit.message, hash[:message]
      assert_equal commit.repo.id, hash[:repo][:id]
      assert_equal commit.repo.name, hash[:repo][:name]
      assert_equal commit.url, hash[:url]
      refute_equal commit.created_at, hash[:created_at]
    end
  end
end
