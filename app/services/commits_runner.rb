module CommitsRunner
  def self.run(trigger_source, commits, repo, pattern = '', opts = {})
    smart = !!opts[:smart]
    formatted_commits =
      if trigger_source == :webhook
        format_webhook(commits, repo)
      elsif trigger_source == :api
        format_api(commits, repo)
      end

    formatted_commits = smart_reorder(formatted_commits) if smart
    formatted_commits.select { |commit| valid?(commit) }
                     .each { |commit| create_and_run(commit, pattern, opts) }
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

  def self.create_and_run(commit, pattern, opts = {})
    Commit.find_or_create_by!(sha1: commit[:sha]) do |c|
      c.url = commit[:url]
      c.message = commit[:message]
      c.repo_id = commit[:repo].id
      c.created_at = commit[:created_at]
    end

    BenchmarkPool.enqueue(
      opts[:initiator_type] || :commit,
      commit[:sha],
      commit[:repo].name,
      opts.merge(include_patterns: pattern)
    )
  end

  def self.smart_reorder(commits)
    return commits if commits.size < 3

    reordered = []
    reordered << commits.first
    reordered << commits[commits.size / 2]
    reordered << commits.last

    depth = 1
    while (reorder_recursive(commits, 1, commits.size - 1, depth, reordered))
      depth += 1
    end
    reordered
  end

  def self.reorder_recursive(commits, first, last, depth, reordered)
    return false if last <= first
    mid = first + (last - first) / 2
    if (depth == 0)
      reordered << commits[mid]
      true
    else
      half1 = reorder_recursive(commits, first, mid, depth - 1, reordered)
      half2 = reorder_recursive(commits, mid + 1, last, depth - 1, reordered)
      half1 || half2
    end
  end
end
