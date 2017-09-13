module ReleasesRunner
  def self.run(versions, repo, pattern = '')
    versions.each { |version| create_and_run(version, repo, pattern) }
  end

  private

  def self.create_and_run(version, repo, pattern)
    Release.find_or_create_by!(version: version, repo_id: repo.id)
    BenchmarkPool.enqueue(
      :release,
      version,
      repo.name,
      include_patterns: pattern
    )
  end
end
