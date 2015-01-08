require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  setup do
    @commit = commits(:rails_commit)
  end

  test ".merge_or_skip_ci? for merge commits" do
    @commit.message = CommitReviewer::MERGE_COMMIT_MESSAGE
    assert_equal true, Commit.merge_or_skip_ci?(@commit.message)
  end

  test ".merge_or_skip_ci? for ci skip commits" do
    @commit.message = CommitReviewer::CI_SKIP_COMMIT_MESSAGE
    assert_equal true, Commit.merge_or_skip_ci?(@commit.message)

    @commit.message = CommitReviewer::SKIP_CI_COMMIT_MESSAGE
    assert_equal true, Commit.merge_or_skip_ci?(@commit.message)
  end

  test ".valid_author?" do
    assert_equal true, Commit.valid_author?('Alan')

    CommitReviewer::INVALID_AUTHORS.each do |author_name|
      assert_equal false, Commit.valid_author?(author_name)
    end
  end
end
