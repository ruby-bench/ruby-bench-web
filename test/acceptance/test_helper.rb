require './test/test_helper'

Dir['./test/acceptance/support/**/*'].each { |file| require file }

class AcceptanceTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::JavaScriptDriver

  self.use_transactional_tests = false

  DatabaseCleaner.strategy = :deletion
  setup { DatabaseCleaner.start }
  teardown  { DatabaseCleaner.clean }
end
