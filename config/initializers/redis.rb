$redis = Redis.new(port: 6379)
RubyBenchWeb::Application.config.cache_store = :redis_store, $redis.client.id
