module CommitsRunner
  def self.run(trigger_source, commits, repo, pattern = '')
    formatted_commits =
      if trigger_source == :webhook
        format_webhook(commits, repo)
      elsif trigger_source == :api
        format_api(commits, repo)
      end

    formatted_commits.select { |commit| valid?(commit) }
                     .each { |commit| create_and_run(commit, pattern) }
                     .count
  end

  private

  def self.format_api(commits, repo)
    commits.map do |commit|
      {
        sha: commit['sha'],
        message: commit['commit']['message'],
        repo: repo,
        url: commit['html_url'],
        created_at: commit['commit']['author']['date'],
        author_name: commit['commit']['author']['name']
      }
    end
  end

  def self.format_webhook(commits, repo)
    commits.map do |commit|
      {
        sha: commit['id'],
        message: commit['message'],
        repo: repo,
        url: commit['url'],
        created_at: commit['timestamp'],
        author_name: commit['author']['name']
      }
    end
  end

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
      :commit,
      commit[:sha],
      commit[:repo].name,
      include_patterns: pattern
    )
  end
end
