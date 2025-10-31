source 'https://rubygems.org'

gem 'importmap-rails'
gem 'jbuilder'
gem 'pg', '~> 1.1'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.2.0'
gem 'stimulus-rails'
gem 'turbo-rails'

# Background jobs
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 7.0'
gem 'sidekiq-cron', '~> 1.12'

# Email parsing
gem 'mail', '~> 2.8'

# Pagination
gem 'kaminari', '~> 1.2'

gem 'bootsnap', require: false
gem 'tzinfo-data', platforms: %i[windows jruby]

# Active Storage
gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Testing
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'rspec-rails', '~> 6.0'

  # Code quality
  gem 'rubocop', '~> 1.57', require: false
  gem 'rubocop-rails', '~> 2.22', require: false
  gem 'rubocop-rspec', '~> 2.25', require: false
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'simplecov', '~> 0.22', require: false
end
