# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

repo = Repo.create!(
  name: 'rails',
  url: 'https://github.com/rails/rails'
)

10.times do |n|
  commit = Commit.create!(
    sha1: Digest::SHA1.hexdigest("#{n}"),
    url: "http://github.com/#{n}",
    message: 'fix something',
    repo_id: repo.id
  )

  BenchmarkRun.create!(
    category: 'allocated_objects',
    result: {
      TOTAL: 2572.755,
      FREE: -85.635,
      T_OBJECT: 56.038,
      T_CLASS: 0.031,
      T_MODULE: 0.01,
      T_FLOAT: 0.0,
      T_STRING: 1250.08,
      T_REGEXP: 3.082,
      T_ARRAY: 642.364,
      T_HASH: 184.842,
      T_STRUCT: 4.029,
      T_BIGNUM: 0.003,
      T_FILE: 2.007,
      T_DATA: 241.096,
      T_MATCH: 31.231,
      T_COMPLEX: 0.0,
      T_RATIONAL: 0.0,
      T_NODE: 243.511,
      T_ICLASS: 0.066
    },
    environment: "About your application's environment\nRails version             5.0.0.alpha\nRuby version              2.1.5-p273 (x86_64-linux)\nRubyGems version          2.4.4\nRack version              1.5\nJavaScript Runtime        therubyracer (V8)\nMiddleware                Rack::Sendfile, ActionDispatch::Static, Rack::Lock, #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x000000030f5700>, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, Rails::Rack::Logger, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions, ActionDispatch::RemoteIp, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActiveRecord::ConnectionAdapters::ConnectionManagement, ActiveRecord::QueryCache, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, ActionDispatch::ParamsParser, Rack::Head, Rack::ConditionalGet, Rack::ETag, Warden::Manager\nApplication root          /home/guoxiang/rails-bench/ko1-test-app\nEnvironment               development\nDatabase adapter          sqlite3\nDatabase schema version   20130808072142\n",
    commit_id: commit.id
  )
end
