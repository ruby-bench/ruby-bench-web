ActiveSupport::Notifications.subscribe('ruby') do |name, start, finish, id, payload|
  RemoteServerJob.perform_later(payload[:commit_sha1], 'ruby_bench')
  RemoteServerJob.perform_later(payload[:commit_sha1], 'ruby_bench_discourse')
end

ActiveSupport::Notifications.subscribe('rails') do |name, start, finish, id, payload|
  RemoteServerJob.perform_later(payload[:commit_sha1], 'discourse_rails_head_bench')
end
