# frozen_string_literal: true

# This is required in Rails 5.2 due to it being a restricted CSP environment
# https://github.com/rails/webpacker#development
# https://github.com/rails/rails/pull/31162
 # if Rails.env.development?
 #   p.script_src :self, :https, :unsafe_eval
 #   p.connect_src :self, :https, 'http://0.0.0.0:3035', 'ws://0.0.0.0:3035'
 # else
 #   p.script_src :self, :https
 # end
