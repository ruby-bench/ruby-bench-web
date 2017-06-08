class CommitsRunner

  def self.run(commits)
    commits.each do |commit|
      if(valid?(commit))
        create(commit)
        BenchmarkPool.enqueue(commit[:repo][:name], commit[:sha])
      end
    end
  end

  private

  def self.valid?(commit)
    !Commit.merge_or_skip_ci?(commit[:message]) && Commit.valid_author?(commit[:author_name])
  end

  def self.create(commit)
    Commit.find_or_create_by(sha1: commit[:sha]) do |c|
      c.url = commit[:url]
      c.message = commit[:message]
      c.repo_id = commit[:repo][:id]
      c.created_at = commit[:created_at]
    end
  end

end
