# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { "World Domination" }
    amount { 100_000 }
    interval { "month" }
    currency { "usd" }
    stripe_id { STRIPE_TEST_PRODUCT_ID }
    initialize_with { Product.where(name: name).first_or_initialize }
  end
end
