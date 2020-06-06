# frozen_string_literal: true

require "stripe"

Stripe.api_key = ENV["STRIPE_API_KEY"]
Stripe.api_version = "2020-03-02"
StripeEvent.signing_secret = ENV["STRIPE_SIGNING_SECRET"]
