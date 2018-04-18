# frozen_string_literal: true

if Rails.env.development?
  Rack::Timeout.timeout = false # Disable
else
  Rack::Timeout.timeout = ENV.fetch('REQUEST_TIMEOUT') { 5 }.to_i
end

Rack::Timeout::Logger.level = Logger::DEBUG
