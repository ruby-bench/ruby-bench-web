class ManualRunner
  def initialize(repo)
    raise "Repo doesn't exist" unless Repo.exists?(repo.id)
    @repo = repo
    @octokit = Octokit::Client.new(access_token: Rails.application.secrets.github_api_token)
  end

  def run_last(commits_count)
    run_paginated(commits_count)
  end

  private

  def run_paginated(commits_count, page = 1)
    unless (commits_count <= 0)
      count_run = run_commits(page)
      run_paginated(commits_count - count_run, page + 1)
    end
  end

  def run_commits(page)
    fetched_commits = @octokit.commits("#{@repo.organization.name}/#{@repo.name}", per_page: 100, page: page)
    formatted_commits = format_commits(fetched_commits)
    CommitsRunner.run(formatted_commits)

    fetched_commits.count
  end

  def format_commits(commits)
    commits.map do |commit|
      {
        sha: commit['sha'],
        message: commit['commit']['message'],
        repo: {
          id: @repo.id,
          name: @repo.name
        },
        url: commit['html_url'],
        created_at: commit['commit']['author']['date'],
        author: {
          name: commit['commit']['author']['name']
        }
      }
    end
  end
end
