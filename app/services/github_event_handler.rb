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
    commits = @payload['commits'] || [@payload['head_commit']]

    commits.each do |commit|
      RemoteServerJob.perform_later(commit['id'])
    end
  end
end
