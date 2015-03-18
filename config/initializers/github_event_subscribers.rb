ActiveSupport::Notifications.subscribe('ruby') do |name, start, finish, id, payload|
  RemoteServerJob.perform_later(payload[:commit_sha1], 'ruby_trunk')
  RemoteServerJob.perform_later(payload[:commit_sha1], 'ruby_trunk_discourse')
end
