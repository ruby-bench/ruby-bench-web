ActiveSupport::Notifications.subscribe('ruby') do |name, start, finish, id, payload|
  RemoteServerJob.perform_later(payload[:commit_sha1], 'ruby_bench')
end
