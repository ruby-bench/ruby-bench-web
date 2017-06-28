require './test/test_helper'
require 'minitest/rails/capybara'

Dir['./test/acceptance/support/**/*'].each { |file| require file }

class AcceptanceTest < Capybara::Rails::TestCase
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
