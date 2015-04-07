require 'redis'

app_path = File.expand_path(File.dirname(__FILE__) + '/..')
working_directory = app_path

worker_processes (ENV["UNICORN_WORKERS"] || 3).to_i

listen (ENV["UNICORN_PORT"] || 3000).to_i

if ENV["RAILS_ENV"] == "production"
  stderr_path "/shared/log/rails/unicorn.stderr.log"
  stdout_path "/shared/log/rails/unicorn.stdout.log"
  pid "#{app_path}/tmp/pids/unicorn.pid"
end

timeout 30

preload_app true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
  defined?(Redis) && Redis.current.disconnect!
end
