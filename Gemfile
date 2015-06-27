source 'https://rubygems.org'
source 'https://rails-assets.org' do
  gem 'rails-assets-highcharts', '~> 4.0.4'
end

gem 'rails', '4.2.3'
gem 'pg'
gem 'sass-rails', '~> 5.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'net-ssh', '~> 2.9.1'
gem 'platform-api', '~> 0.2.0'
gem 'haml', '~> 4.0.5'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'autoprefixer-rails', '~> 5.1.11'
gem 'pygments.rb', '~> 0.6.0'
gem 'redis', '~> 3.2.1'
gem 'redis-rails', '~> 4.0.0'
gem 'sidekiq', '~> 3.3.3'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'turbolinks', '~> 2.5.3'

group :development do
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet', '~> 4.14.0'
end

group :development, :test do
  gem 'byebug'
end

group :test do
  gem 'mocha', '~> 1.1.0'
  gem 'vcr', '~> 2.9.3'
  gem 'webmock', '~> 1.20.4'
  gem 'capybara', '~> 2.4.4'
  gem 'capybara-webkit', '~> 1.3.1'
  gem 'launchy', '~> 2.4.3'
  gem 'selenium-webdriver', '~> 2.45.0'
  gem 'minitest-stub-const', '~> 0.3'
  gem 'factory_girl_rails', '~> 4.5.0'
end

group :production, :development do
  gem 'unicorn', '~> 4.8.3'
  gem 'rack-mini-profiler', '~> 0.9.3'
  gem 'logster', '~> 0.8.0'
  gem 'sinatra', '~> 1.4.6'
end

group :production do
  gem 'rails_12factor'
  gem 'newrelic_rpm'
  gem 'bugsnag', '~> 2.8.4'
end
