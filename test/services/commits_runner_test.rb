require 'test_helper'

class CommitsRunnerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @repo = create(:repo, name: 'rails')
  end

  test '#run commits triggered by webhook' do
    commits = [
      {
        'id' => '12345',
        'message' => 'My beautiful commit message',
        'author' => {
          'name' => 'bmarkons'
        },
        'url' => 'https://github.com/commit',
        'timestamp' => 12345
      }
    ]

    CommitsRunner.run(:webhook, commits, @repo)

    expect_created(commits)
    assert_enqueued_jobs(commits.count)
  end

  test '#run can do smart reorder' do
    commits = []
    10.times do |n|
      commits << {
        'sha' => "abcd#{n}",
        'commit' => {
          'message' => 'My beautiful commit message',
          'author' => {
            'date' => 12345,
            'name' => 'bmarkons'
          }
        },
        'html_url' => 'https://github.com/commit'
      }
    end
    CommitsRunner.run(:api, commits, @repo, '', smart: true)

    expect_created(commits)
    assert_enqueued_jobs(commits.count)
    order = Commit
            .unscope(:order)
            .where(sha1: commits.map { |c| c['sha'] })
            .order('created_at ASC')
            .pluck(:sha1)

    expected_order = [0, 5, 9, 3, 7, 2, 4, 6, 8, 1].map { |n| "abcd#{n}" }
    assert_equal(expected_order, order)
  end

  test '#run commits triggered manually' do
    commits = [
      {
        'sha' => '12345',
        'commit' => {
          'message' => 'My beautiful commit message',
          'author' => {
            'date' => 12345,
            'name' => 'bmarkons'
          }
        },
        'html_url' => 'https://github.com/commit'
      }
    ]

    CommitsRunner.run(:api, commits, @repo)

    expect_created(commits)
    assert_enqueued_jobs(commits.count)
  end

  def expect_created(commit_hashes)
    commit_hashes.each do |commit_hash|
      commit = Commit.find_by!(sha1: commit_hash['sha'] || commit_hash['id'])

      assert_equal commit_hash['id'] || commit_hash['sha'], commit.sha1
      assert_equal commit_hash['message'] || commit_hash['commit']['message'], commit.message
      assert_equal @repo.id, commit.repo.id
      assert_equal @repo.name, commit.repo.name
      assert_equal commit_hash['url'] || commit_hash['html_url'], commit.url
      refute_equal commit_hash['timestamp'] || commit_hash['commit']['author']['date'], commit.created_at
    end
  end
end
