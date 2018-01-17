source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0.beta2'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'

# Use Puma as the app server
gem 'puma', '~> 3.10'

# Use Rack Timeout. Read more: https://github.com/heroku/rack-timeout
gem 'rack-timeout', '~> 0.4'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# TODO: Consider replacing with active_model_serializers
gem 'jbuilder', '~> 2.5'

# Use Redis Rails to set up a Redis backed Cache and / or Session
gem 'redis-rails', '~> 5.0'

# Use Font Awesome Rails for Font Awesome icons
gem 'font-awesome-rails', '~> 4.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Pretty html abstractions
gem 'haml', '~> 5'
gem 'simple_form'

# Authentication
gem 'devise'
# Authorization
gem 'pundit'

# Pretty admin dashboards
gem 'administrate'

gem 'receipts'
# Stripe stuff
gem 'stripe'
gem 'stripe_event', '~> 1.8'

# Upload to S3 directly
gem 'aws-sdk'

# Process images
gem 'image_processing'
gem 'mini_magick', '>= 4.3.5'

# Impersonate other users
gem 'pretender'

# Search
gem 'searchkick'

# Jerbs
gem 'sidekiq', '~> 5.0'

# Feature flagging
gem 'rollout'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'database_cleaner', '~> 1.6'
  gem 'ffaker', '~> 2.7'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'capybara', '~> 2.13'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'pry'
  gem 'rspec-rails', '~> 3.6'
  gem 'selenium-webdriver'
  gem 'stripe-ruby-mock', '~> 2.5', require: 'stripe_mock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'
