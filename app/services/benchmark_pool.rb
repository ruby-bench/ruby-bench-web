module BenchmarkPool
  def self.enqueue(repo_name, commit_sha)
    case repo_name
    when 'ruby'
      RemoteServerJob.perform_later(commit_sha, 'ruby_trunk')
      # FIXME: Benchmark is failling on Ruby 2.3
      # RemoteServerJob.perform_later(commit_sha, 'ruby_trunk_discourse')
    when 'rails'
      RemoteServerJob.perform_later(commit_sha, 'rails_trunk')
    else
      raise ArgumentError, "unknown repo: #{repo_name}"
    end
  end
end
