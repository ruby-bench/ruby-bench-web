class ManualRunner

  def initialize(repo)
    raise "Repo doesn't exist" unless Repo.exist?(repo)
    @repo = repo
  end

  def run_commits_since(date)
    fetched_commits = fetch_commits_since(date)
    formatted_commits = format_commits(fetched_commits)

    CommitsRunner.run(formated_commits)
  end

  private

  def fetch_commits_since(date)
    Octokit.auto_paginate = true
    Octokit.commits_since("#{repo.organization.name}/#{repo.name}", since_date)
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
          name: commit['author']['name']
        }
      }
    end
  end
end
