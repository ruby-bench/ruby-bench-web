module BenchmarkPool
  def self.enqueue(initiator_type, initiator, repo_name, options = {})
    case repo_name
    when 'ruby'
      RemoteServerJob.perform_later(initiator, "ruby_#{initiator_type}", options)
    when 'rails'
      RemoteServerJob.perform_later(initiator, "rails_#{initiator_type}", options)
    when 'sequel'
      RemoteServerJob.perform_later(initiator, "sequel_#{initiator_type}", options)
    when 'ruby-pg'
      RemoteServerJob.perform_later(initiator, "pg_#{initiator_type}", options)
    else
      raise ArgumentError, "unknown repo: #{repo_name}"
    end
  end
end
