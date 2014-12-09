require 'capybara/rails'

Capybara.javascript_driver = :webkit

module Capybara
  module JavaScriptDriver
    def require_js
      Capybara.current_driver = :webkit
    end

    def teardown
      super
      Capybara.use_default_driver
    end
  end
end
