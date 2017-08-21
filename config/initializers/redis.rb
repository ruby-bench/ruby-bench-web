$redis = if Rails.env.production?
           Redis.new(port: 6379)
         else
           Redis.new(url: 'redis://redis:6379')
         end
RubyBenchWeb::Application.config.cache_store = :redis_store, $redis.client.id
