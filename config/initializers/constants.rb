# frozen_string_literal: true

# Application wide constants
TRIAL_PERIOD_DAYS = ENV["TRIAL_PERIOD_DAYS"] || 14

# Write stripe events to seperate log
STRIPE_LOG_PATH = "log/stripe.log"

# NOTE To test against live stripe, create your test product on stripe, and set your ENV vars
STRIPE_TEST_PRODUCT_BASIC_ID = ENV["STRIPE_TEST_PRODUCT_BASIC_ID"] || "replace-this-product-id"
STRIPE_TEST_PLAN_BASIC_MONTH_ID = ENV["STRIPE_TEST_PLAN_BASIC_MONTH_ID"] || "replace-this-plan-id"
STRIPE_TEST_PLAN_BASIC_YEAR_ID = ENV["STRIPE_TEST_PLAN_BASIC_YEAR_ID"] || "replace-this-plan-id"

STRIPE_TEST_PRODUCT_PRO_ID = ENV["STRIPE_TEST_PRODUCT_PRO_ID"] || "replace-this-product-id"
STRIPE_TEST_PLAN_PRO_MONTH_ID= ENV["STRIPE_TEST_PLAN_PRO_MONTH_ID"] || "replace-this-plan-id"
STRIPE_TEST_PLAN_PRO_YEAR_ID = ENV["STRIPE_TEST_PLAN_PRO_YEAR_ID"] || "replace-this-plan-id"
