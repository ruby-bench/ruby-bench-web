ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'capybara-screenshot/minitest'
require 'sidekiq/testing'

Dir["#{Rails.root}/test/support/**/*"].each { |file| require file }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  include FactoryGirl::Syntax::Methods
end

Sidekiq::Testing.fake!

module MiniTest::Assertions
  def assert_matched_arrays(expected, actual)
    expected_array = expected.to_ary
    assert_kind_of Array, expected_array
    actual_array = actual.to_ary
    assert_kind_of Array, actual_array
    assert_equal expected_array.sort, actual_array.sort
  end
end
