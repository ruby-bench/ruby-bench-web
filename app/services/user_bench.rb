class UserBench
  attr_reader :errors, :name, :url, :sha, :sha2, :commits

  def initialize(name, url, sha, sha2 = nil)
    @name = name&.strip
    @url = url&.strip
    @sha = sha&.strip
    @sha2 = sha2&.strip
    @errors = []
    @commits = []
    @client = Octokit::Client.new(access_token: Rails.application.secrets.github_api_token)
  end

  def validate!
    errors.push(err('missing_name')) if name.blank?
    errors.push(err('missing_url')) if url.blank?
    errors.push(err('missing_sha')) if sha.blank?
    return if !valid?

    errors.push(err('name_already_taken')) if name_taken?
    errors.push(err('bad_url')) unless valid_url?
    errors.push(err('unallowed_characters', name: name)) unless valid_name?

    return if !valid?

    validate_sha(sha)
    validate_sha(sha2) if sha2.present?
  end

  def valid?
    @errors.size == 0
  end

  def run
    repo = Repo.find_or_create_by!(
      name: 'ruby',
      url: 'https://github.com/tgxworld/ruby',
      organization: Organization.find_or_create_by!(
        name: 'ruby',
        url: 'https://github.com/tgxworld/',
      )
    )
    BenchmarkType.create!(
      category: name,
      script_url: url,
      from_user: true,
      repo: repo
    )

    RunUserBench.perform_later(name, url, commits.last.commit.committer.date.iso8601, commits.first.sha)
  end

  private

  def valid_url?
    uri = URI.parse(url)
    URI::HTTP === uri || URI::HTTPS === uri
  rescue URI::InvalidURIError
    false
  end

  def name_taken?
    BenchmarkType.exists?(category: name)
  end

  def valid_name?
    name.match?(/^[a-zA-Z0-9\-_]+$/)
  end

  def validate_sha(sha)
    commit = @client.commit('ruby/ruby', sha)
    add_commit(commit)
  rescue Octokit::UnprocessableEntity
    errors.push(err('bad_sha', sha: sha))
  end

  def add_commit(commit)
    if commits.all? { |c| c.sha != commit.sha }
      commits.push(commit)
      commits.sort_by! { |c| c.commit.committer.date }
    end
  end

  def err(key, *args)
    I18n.t("user_scripts.errors.#{key}", *args)
  end
end
