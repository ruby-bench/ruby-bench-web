require 'net/http'

class UserBench
  attr_reader :errors, :url, :sha, :sha2, :commits, :names

  def initialize(name, url, sha, sha2 = nil)
    @name = name&.strip
    @url = url&.strip
    @sha = sha&.strip
    @sha2 = sha2&.strip
    @names = []
    @errors = []
    @commits = []
    @client = Octokit::Client.new(access_token: Rails.application.secrets.github_api_token)
  end

  def validate!
    errors.push(err('missing_name')) if @name.blank?
    errors.push(err('missing_url')) if url.blank?
    errors.push(err('missing_sha')) if sha.blank?
    return if !valid?

    errors.push(err('bad_url')) unless valid_url?
    errors.push(err('unallowed_characters', name: @name)) unless valid_name?
    return if !valid?

    if !yaml_script? && !ruby_script?
      errors.push(err('unkown_extension', url: url))
      return
    end

    validate_yaml if yaml_script?
    validate_names
    validate_script if ruby_script?
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
    @names.each do |ty|
      BenchmarkType.create!(
        category: ty,
        script_url: url,
        from_user: true,
        repo: repo
      )
    end

    RunUserBench.perform_later(@name, url, commits.last.commit.committer.date.iso8601, commits.first.sha)
  end

  private

  def validate_names
    if yaml_script? && Hash === @parsed_yaml
      benchmark = @parsed_yaml['benchmark']
      if Array === benchmark
        benchmark.each { |hash| @names << hash['name'] }
      elsif Hash === benchmark
        benchmark.keys.each { |n| @names << n }
      elsif String === benchmark
        @names << benchmark
      end
    end

    if yaml_script? && @names.size == 0
      errors.push(err('yaml_file_without_benchmarks'))
      return
    elsif ruby_script?
      @names << @name
    end

    taken_names = BenchmarkType.where(category: @names).pluck(:category)
    if taken_names.size > 0
      errors.push(err('name_already_taken', names: taken_names.join(', ')))
    end
  end

  def yaml_script?
    url.match?(/\.ya?ml$/)
  end

  def ruby_script?
    url.end_with?('.rb')
  end

  def validate_script
    content = Net::HTTP.get(URI.parse(url)).strip
    content.force_encoding(Encoding::UTF_8)
    path = File.join(Dir.tmpdir, SecureRandom.hex)
    File.open(path, 'wt') { |file| file.write(content) }
    if !system("ruby -c #{path} > /dev/null 2>&1")
      errors.push(err('invalid_ruby_code', lines: CGI.escapeHTML(content.split("\n").first(5).join("\n"))))
    end
    File.delete(path)
  end

  def validate_yaml
    yaml = Net::HTTP.get(URI.parse(url))
    @parsed_yaml = YAML.safe_load(yaml)
  rescue Psych::SyntaxError, Psych::DisallowedClass
    errors.push(err('invalid_yaml'))
  end

  def valid_url?
    uri = URI.parse(url)
    URI::HTTP === uri || URI::HTTPS === uri
  rescue URI::InvalidURIError
    false
  end

  def valid_name?
    @name.match?(/^[a-zA-Z0-9\-_]+$/)
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
