# https://devcenter.heroku.com/articles/rails-unicorn
require 'redis'

worker_processes 3
timeout 15
preload_app true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
  defined?(Redis) && Redis.current.disconnect!
end
