if Rails.env.production? && ENV['SENTRY_DSN']
  Raven.configure { |config| config.dsn = ENV['SENTRY_DSN'] }
end
