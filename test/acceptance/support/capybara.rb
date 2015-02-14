require 'capybara/rails'

Capybara.javascript_driver = :webkit

module Capybara
  module JavaScriptDriver
    def before_setup
      super
      Capybara.current_driver = :webkit
    end

    def teardown
      Capybara.use_default_driver
      super
    end
  end
end
