module BenchmarkPool
  def self.enqueue(repo_name, commit_sha)
    case repo_name
    when 'ruby'
      RemoteServerJob.perform_later(commit_sha, 'ruby_trunk')
    when 'rails'
      RemoteServerJob.perform_later(commit_sha, 'rails_trunk')
    when 'sequel'
      RemoteServerJob.perform_later(commit_sha, 'sequel_trunk')
    else
      raise ArgumentError, "unknown repo: #{repo_name}"
    end
  end
end
