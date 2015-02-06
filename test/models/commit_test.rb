require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  test ".merge_or_skip_ci? for merge commits" do
    assert_equal true, Commit.merge_or_skip_ci?(CommitReviewer::MERGE_COMMIT_MESSAGE)
    assert_equal false, Commit.merge_or_skip_ci?('haha')
  end

  test ".merge_or_skip_ci? for ci skip commits" do
    assert_equal true, Commit.merge_or_skip_ci?(CommitReviewer::CI_SKIP_COMMIT_MESSAGE)
    assert_equal true, Commit.merge_or_skip_ci?(CommitReviewer::SKIP_CI_COMMIT_MESSAGE)
    assert_equal true, Commit.merge_or_skip_ci?(CommitReviewer::SKIP_CI_COMMIT_MESSAGE.upcase)
    assert_equal true, Commit.merge_or_skip_ci?(CommitReviewer::SKIP_CI_COMMIT_MESSAGE.upcase)
  end

  test ".valid_author?" do
    assert_equal true, Commit.valid_author?('Alan')

    CommitReviewer::INVALID_AUTHORS.each do |author_name|
      assert_equal false, Commit.valid_author?(author_name)
    end
  end
end
