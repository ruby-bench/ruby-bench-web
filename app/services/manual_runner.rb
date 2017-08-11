class ManualRunner
  OPTIONS = ['1', '20', '100', '200', '500', '750', '2000']

  def initialize(repo)
    raise "Repo doesn't exist" unless Repo.exists?(repo.id)
    @repo = repo
    @octokit = Octokit::Client.new(access_token: Rails.application.secrets.github_api_token)
  end

  def run_last(commits_count, pattern: '')
    if commits_count < 100
      run_commits(per_page: commits_count, pattern: pattern)
    else
      run_paginated(commits_count, pattern: pattern)
    end
  end

  private

  def run_paginated(commits_count, page: 1, pattern: '')
    unless (commits_count <= 0)
      count_run = run_commits(page: page, pattern: pattern)
      run_paginated(commits_count - count_run, page: page + 1, pattern: pattern)
    end
  end

  def run_commits(page: 1, per_page: 100, pattern: '')
    fetched_commits = @octokit.commits("#{@repo.organization.name}/#{@repo.name}", per_page: per_page, page: page)
    formatted_commits = format_commits(fetched_commits)
    CommitsRunner.run(formatted_commits, pattern)

    fetched_commits.count
  end

  def format_commits(commits)
    commits.map do |commit|
      {
        sha: commit['sha'],
        message: commit['commit']['message'],
        repo: @repo,
        url: commit['html_url'],
        created_at: commit['commit']['author']['date'],
        author_name: commit['commit']['author']['name']
      }
    end
  end
end
