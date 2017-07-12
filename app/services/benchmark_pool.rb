module BenchmarkPool
  def self.enqueue(repo_name, commit_sha, options = {})
    case repo_name
    when 'ruby'
      RemoteServerJob.perform_later(commit_sha, 'ruby_trunk', options)
      # RemoteServerJob.perform_later(commit_sha, 'ruby_trunk_discourse')
    when 'rails'
      RemoteServerJob.perform_later(commit_sha, 'rails_trunk', options)
    when 'sequel'
      RemoteServerJob.perform_later(commit_sha, 'sequel_trunk', options)
    else
      raise ArgumentError, "unknown repo: #{repo_name}"
    end
  end
end
