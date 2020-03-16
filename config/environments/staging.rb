# frozen_string_literal: true

require_relative "production.rb"

Rails.application.configure do
  # Overwrite any production settings here, or if you want to start from
  # scratch then remove line 1.

  # Use AWS for active storage for staging
  config.active_storage.service = :amazon
end
