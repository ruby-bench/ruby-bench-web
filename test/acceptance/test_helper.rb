require "#{Rails.root}/test/test_helper"

Dir["#{Rails.root}/test/acceptance/support/**/*"].each { |file| require file }

class AcceptanceTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::JavaScriptDriver
end
