# frozen_string_literal: true

Rails.application.configure do
  # NOTE Required to inline mail delivery so it can be picked up by letter_opener
  require "sidekiq/testing/inline"

  # Settings specified here will take precedence over those in config/application.rb.
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true

  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true

  # Allow rendering console from outside docker network
  config.web_console.whiny_requests = false

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Shut up the logs for tests
  config.log_level = "debug"

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=172800"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.action_mailer.preview_path = "test/mailers/previews"
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_caching = false
  # NOTE Switch the comments of the following lines to enable real sending in development
  config.action_mailer.delivery_method = :letter_opener
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: ENV["SMTP_ADDRESS"],
  #   port: ENV["SMTP_PORT"].to_i,
  #   domain: ENV["SMTP_DOMAIN"],
  #   user_name: ENV["SMTP_USERNAME"],
  #   password: ENV["SMTP_PASSWORD"],
  #   authentication: ENV["SMTP_AUTH"],
  #   enable_starttls_auto: ENV["SMTP_ENABLE_STARTTLS_AUTO"] == "true"
  # }


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # For devise
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Use AWS for active storage as a default
  config.active_storage.service = :local

  # In case you want to use subdomains
  config.hosts << "lvh.me"
end
