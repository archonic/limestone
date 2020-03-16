# frozen_string_literal: true

# Application wide constants
TRIAL_PERIOD_DAYS = ENV["TRIAL_PERIOD_DAYS"] || 14

# Write stripe events to seperate log
STRIPE_LOG_PATH = "log/stripe.log"
