require 'net/ssh'

class GithubEventHandler
  PUSH = "push".freeze
  HEADER = 'HTTP_X_GITHUB_EVENT'.freeze

  def initialize(request, payload)
    @request = request
    @payload = payload
  end

  def handle
    case @request.env[HEADER]
    when PUSH
      process_push
    end
  end

  private

  # Grabs the commits hash and starts job to run benchmarks on remote server.
  def process_push
    repo = first_or_create_repo(@payload['repository'])
    commits = @payload['commits'] || [@payload['head_commit']]

    commits.each do |commit|
      if create_commit(commit, repo.id)
        RemoteServerJob.perform_later(commit['id'])
      end
    end
  end

  def first_or_create_repo(repository)
    Repo.find_or_create_by(name: repository['name'], url: repository['html_url'])
  end

  def create_commit(commit, repo_id)
    if !Commit.merge_or_skip_ci?(commit['message'])
      Commit.create!(
        sha1: commit['id'],
        url: commit['url'],
        message: commit['message'],
        repo_id: repo_id,
        created_at: commit['timestamp']
      )
    end
  end
end
