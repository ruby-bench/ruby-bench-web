class CommitsRunner
  def self.run(commits, pattern = '')
    commits.select { |commit| valid?(commit) }
           .each { |commit| create_and_run(commit, pattern) }
           .count
  end

  private

  def self.valid?(commit)
    !Commit.merge_or_skip_ci?(commit[:message]) && Commit.valid_author?(commit[:author_name])
  end

  def self.create_and_run(commit, pattern)
    Commit.find_or_create_by!(sha1: commit[:sha]) do |c|
      c.url = commit[:url]
      c.message = commit[:message]
      c.repo_id = commit[:repo].id
      c.created_at = commit[:created_at]
    end

    BenchmarkPool.enqueue(
      commit[:repo].name,
      commit[:sha],
      include_patterns: pattern
    )
  end
end
