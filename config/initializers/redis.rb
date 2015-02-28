$redis =
  if ENV["REDISCLOUD_URL"]
    Redis.new(url: ENV["REDISCLOUD_URL"])
  else
    Redis.new(port: 6379)
  end

redis_url = ENV["REDISCLOUD_URL"] || $redis.client.id

RubyBenchWeb::Application.config.cache_store = :redis_store, redis_url
