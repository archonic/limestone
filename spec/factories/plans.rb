# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    name { "World Domination Monthly" }
    amount { 100_000 }
    interval { "month" }
    currency { "USD" }
    stripe_id { STRIPE_TEST_PRODUCT_ID }
    initialize_with { Plan.where(name: name).first_or_initialize }
  end
end
