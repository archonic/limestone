# frozen_string_literal: true

require "flipper"
require "flipper/adapters/redis"

# FEATURES:
# public_registration

Flipper.configure do |config|
  config.default do
    client = Redis.new(url: "#{ENV['REDIS_BASE_URL']}flipper")
    adapter = Flipper::Adapters::Redis.new(client)
    Flipper.new adapter
  end

  # Register each role as a group
  Flipper.register(:admin) do |actor|
    actor.respond_to?(:admin?) && actor.admin?
  end

  Flipper.register(:basic) do |actor|
    actor.respond_to?(:basic?) && actor.basic?
  end

  Flipper.register(:pro) do |actor|
    actor.respond_to?(:pro?) && actor.pro?
  end

  Flipper.register(:removed) do |actor|
    actor.respond_to?(:removed?) && actor.removed?
  end
end
