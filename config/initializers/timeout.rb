# frozen_string_literal: true

Rack::Timeout.timeout = if Rails.env.development?
                          false
                        else
                          ENV.fetch('REQUEST_TIMEOUT') { 5 }.to_i
                        end
Rack::Timeout::Logger.level = Logger::DEBUG
