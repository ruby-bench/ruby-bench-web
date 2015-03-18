ActiveSupport::Notifications.subscribe('ruby') do |name, start, finish, id, payload|
  RemoteServerJob.perform_later(payload[:commit_sha1], 'ruby_trunk')
  RemoteServerJob.perform_later(payload[:commit_sha1], 'ruby_trunk_discourse')
end

ActiveSupport::Notifications.subscribe('rails') do |name, start, finish, id, payload|
  RemoteServerJob.perform_later(payload[:commit_sha1], 'discourse_rails_head_bench')
end
