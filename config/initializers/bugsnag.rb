if Rails.env.production?
  Bugsnag.configure { |config| config.api_key = ENV['BUGSNAG_API_TOKEN'] }
end
