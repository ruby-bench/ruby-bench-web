require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

module Capybara
  module JavaScriptDriver
    def require_js
      Capybara.current_driver = :poltergeist
    end

    def reset_driver
      Capybara.use_default_driver
    end
  end
end
