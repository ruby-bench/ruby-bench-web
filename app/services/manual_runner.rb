class ManualRunner
  OPTIONS = ['1', '20', '100', '200', '500', '750', '2000']

  def initialize(repo)
    raise "Repo doesn't exist" unless Repo.exists?(repo.id)
    @repo = repo
    @octokit = Octokit::Client.new(access_token: Rails.application.secrets.github_api_token)
  end

  def run_releases(versions, pattern: '')
    ReleasesRunner.run(versions, @repo, pattern)
  end

  def run_last(commits_count, pattern: '')
    commits = fetch_commits(commits_count)
    CommitsRunner.run(:api, commits, @repo, pattern, smart: true)
  end

  private

  def fetch_commits(commits_count)
    commits = []

    runs = commits_count.ceil(-2) / 100
    per_page = [commits_count, 100].min

    runs.times do |n|
      page = n + 1
      batch = @octokit.commits("#{@repo.organization.name}/#{@repo.name}", per_page: per_page, page: page)
      commits.push(*batch)
    end

    commits.pop(commits.size - commits_count)
    commits
  end
end
