require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  setup do
    @commit = commits(:rails_commit)
  end

  test ".merge_or_skip_ci? for merge commits" do
    @commit.message = Commit::MERGE_COMMIT_MESSAGE
    assert_equal true, Commit.merge_or_skip_ci?(@commit.message)
  end

  test ".merge_or_skip_ci? for ci skip commits" do
    @commit.message = Commit::CI_SKIP_COMMIT_MESSAGE
    assert_equal true, Commit.merge_or_skip_ci?(@commit.message)

    @commit.message = Commit::SKIP_CI_COMMIT_MESSAGE
    assert_equal true, Commit.merge_or_skip_ci?(@commit.message)
  end
end
