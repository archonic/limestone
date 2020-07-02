# frozen_string_literal: true

sidekiq_config = { url: ENV["ACTIVE_JOB_URL"] }

Sidekiq.configure_server do |config|
  # NOTE docker-compose redis uses an AOF file which grows indefinitely
  # This increases startup time until the volume is wiped.
  # Delete the volume if this becomes unreasonably long (provided the data is not needed).
  sleep 10
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
