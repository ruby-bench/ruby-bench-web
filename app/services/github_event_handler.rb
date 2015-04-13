class GithubEventHandler
  PUSH = "push"
  HEADER = 'HTTP_X_GITHUB_EVENT'

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
        ActiveSupport::Notifications.instrument(
          repo.name, { commit_sha1: commit['id'] }
        )
      end
    end
  end

  def first_or_create_repo(repository)
    organization_name, repo_name = parse_full_name(repository['full_name'])
    repository_url = repository['html_url']

    # Remove this once Github hook is actually coming from the original Ruby
    # repo.
    if organization_name == 'tgxworld'
      organization_name = 'ruby'
    end

    organization = Organization.find_or_create_by(
      name: organization_name, url: repository_url[0..((repository_url.length - 1) - repo_name.length)]
    )

    Repo.find_or_create_by(
      name: repo_name, url: repository_url, organization_id: organization.id
    )
  end

  def parse_full_name(full_name)
    full_name =~ /\A(\w+)\/(\w+)/
    [$1, $2]
  end

  def create_commit(commit, repo_id)
    if !Commit.merge_or_skip_ci?(commit['message']) && Commit.valid_author?(commit['author']['name'])
      Commit.find_or_create_by(sha1: commit['id']) do |c|
        c.url = commit['url']
        c.message = commit['message']
        c.repo_id = repo_id
        c.created_at = commit['timestamp']
      end
    end
  end
end
