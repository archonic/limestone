# frozen_string_literal: true

sidekiq_config = { url: ENV["ACTIVE_JOB_URL"] }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config

  # NOTE docker-compose uses an AOF file which grows indefinitely
  # This increases startup time until the AOF is rewritten or the volume is deleted
  # run `docker-compose exec redis redis-cli -a yourpassword` then `BGREWRITEAOF` to rewrite AOF
  sleep 5 if Rails.env.development?

  # TODO Uncomment if you create a job schedule in config/schedule.yml
  # Sidekiq::Cron::Job.load_from_hash YAML.load_file("config/schedule.yml")
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
