module CommitReviewer
  MERGE_COMMIT_MESSAGE = 'Merge pull request'
  CI_SKIP_COMMIT_MESSAGE = 'ci skip'
  SKIP_CI_COMMIT_MESSAGE = 'skip ci'
  INVALID_AUTHORS = ['svn']

  def merge_or_skip_ci?(message)
    !message.match(
      /#{CI_SKIP_COMMIT_MESSAGE}|#{MERGE_COMMIT_MESSAGE}|#{SKIP_CI_COMMIT_MESSAGE}/
    ).nil?
  end

  def valid_author?(author_name)
    !INVALID_AUTHORS.include?(author_name)
  end
end
