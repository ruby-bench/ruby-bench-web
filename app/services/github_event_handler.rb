# frozen_string_literal: true

class GithubEventHandler
  PUSH = 'push'
  HEADER = 'HTTP_X_GITHUB_EVENT'

  def initialize(request, payload)
    @request = request
    @payload = payload
  end

  def handle
    process_push if push_to_main_branch?
  end

  private

  def push_to_main_branch?
    @request.env[HEADER] == PUSH && branch_from_payload == "master"
  end

  def branch_from_payload
    @payload['ref'].split('/')[2]
  end

  def process_push
    repo = find_or_create_repo(@payload['repository'])
    commits = @payload['commits'] || [@payload['head_commit']]

    CommitsRunner.run(:webhook, commits, repo)
  end

  def find_or_create_repo(repository)
    organization_name, repo_name = parse_full_name(repository['full_name'])
    repository_url = repository['html_url']

    # Remove this once Github hook is actually coming from the original Ruby
    # repo.
    case [organization_name, repo_name]
    when ['tgxworld', 'ruby']
      organization_name = 'ruby'
    when ['tgxworld', 'rails']
      organization_name = 'rails'
    when ['tgxworld', 'bundler']
      organization_name = 'bundler'
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
end
