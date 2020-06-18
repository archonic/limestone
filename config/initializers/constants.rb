# frozen_string_literal: true

# Application wide constants
TRIAL_PERIOD_DAYS = ENV["TRIAL_PERIOD_DAYS"] || 14

# Write stripe events to seperate log
STRIPE_LOG_PATH = "log/stripe.log"

# NOTE To test against live stripe, create your test product on stripe, and replace this ID
STRIPE_TEST_PRODUCT_ID = ENV["STRIPE_TEST_PRODUCT_ID"] || "replace-this-product-id"
STRIPE_TEST_PLAN_ID = ENV["STRIPE_TEST_PLAN_ID"] || "replace-this-plan-id"
