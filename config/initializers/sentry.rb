if Rails.env.production?
  Raven.configure { |config| config.dsn = ENV['SENTRY_DSN'] }
end
