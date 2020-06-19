# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { "Basic" }
    stripe_id { STRIPE_TEST_PRODUCT_BASIC_ID }
    initialize_with { Product.where(name: name).first_or_initialize }
    
    trait :pro do
      name { "Pro" }
      stripe_id { STRIPE_TEST_PRODUCT_PRO_ID }
    end
  end
end
