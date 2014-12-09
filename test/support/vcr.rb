require 'vcr'
require 'webmock/minitest'

VCR.configure do |c|
  c.cassette_library_dir = "#{Rails.root}/test/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
end
