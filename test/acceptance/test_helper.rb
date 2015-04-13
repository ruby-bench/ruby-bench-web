require "./test/test_helper"

Dir["./test/acceptance/support/**/*"].each { |file| require file }

class AcceptanceTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::JavaScriptDriver
end
