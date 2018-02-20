require 'flipper'
require 'flipper/adapters/redis'

# FEATURES:
# public_registration

Flipper.configure do |config|
  config.default do
    client = Redis.new(url: "#{ENV['REDIS_BASE_URL']}flipper")
    adapter = Flipper::Adapters::Redis.new(client)
    $flipper = Flipper.new adapter
  end
end
