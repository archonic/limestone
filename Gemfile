# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

# Pretty admin dashboards
gem "administrate", "~> 0.13"

# Upload to S3 directly
gem "aws-sdk-s3", "~> 1"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Authentication
gem "devise", "~> 4"

# Soft deletes for ActiveRecord done right
gem "discard", "~> 1"

# Feature flagging
gem "flipper"
gem "flipper-redis"
gem "flipper-ui"

# Pretty html abstractions
gem "haml", "~> 5"

# Process images
gem "image_processing", "~> 1"
gem "mini_magick", ">= 4.3.5"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.2"

# Impersonate other users
gem "pretender", "~> 0.3"

# Authorization
gem "pundit", "~> 1"

# Use Puma as the app server
gem "puma", "~> 4"

# Use Rack Timeout. Read more: https://github.com/heroku/rack-timeout
gem "rack-timeout", "~> 0.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6"

# Use SCSS for stylesheets
gem "sass-rails", "~> 5"

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"

gem "simple_form", "~> 5"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", ">= 4"

# Search
gem "searchkick", "~> 3"

# Jerbs
gem "sidekiq", "~> 5"

# Payment stuff
gem "pay", "~> 2.0"
gem "stripe", "< 6.0", ">= 2.8"
gem "stripe_event", "~> 2.3"

gem "minitest", "~> 5.14"

# Send mail via service
gem "sendgrid-ruby", "~> 6.3"

group :development do
  gem "haml-lint", require: false
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "database_cleaner", "~> 1.6"
  gem "faker", "~> 2.13"
  gem "shoulda-matchers", "~> 3.1"
  gem "simplecov", require: false
end

group :development, :test do
  gem "factory_bot_rails", "~> 4.8"
  gem "pry"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 3.6"
  gem "rspec_junit_formatter"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-performance"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"
