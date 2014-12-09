require "#{Rails.root}/test/test_helper"
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :webkit

class AcceptanceTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
end
