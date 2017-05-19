require "./test/test_helper"

Dir["./test/acceptance/support/**/*"].each { |file| require file }

class AcceptanceTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::JavaScriptDriver
  include Capybara::Screenshot::MiniTestPlugin

  self.use_transactional_tests = false

  DatabaseCleaner.strategy = :deletion

  setup do
    DatabaseCleaner.start
    require_js
  end

  teardown do
    DatabaseCleaner.clean
    reset_driver
  end
end
