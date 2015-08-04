require 'capybara/rails'

Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end

module Capybara
  module JavaScriptDriver
    def require_js
      Capybara.current_driver = :webkit
    end

    def reset_driver
      Capybara.use_default_driver
    end
  end
end
