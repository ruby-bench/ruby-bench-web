ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'capybara-screenshot/minitest'

Dir["#{Rails.root}/test/support/**/*"].each { |file| require file }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  include FactoryGirl::Syntax::Methods

  def self.file_fixture(name)
    Rails.root.join('test', 'fixtures', 'files', name)
  end
end
