# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    name { "Basic Monthly" }
    amount { 900 }
    interval { "month" }
    currency { "USD" }
    stripe_id { STRIPE_TEST_PLAN_BASIC_MONTH_ID }
    initialize_with { Plan.where(name: name).first_or_initialize }
    
    trait :basic_annual do
      name { "Basic Annual" }
      amount { 9900 }
      interval { "year" }
      stripe_id { STRIPE_TEST_PLAN_BASIC_YEAR_ID }
    end

    trait :pro_monthly do
      name { "Pro Monthly" }
      amount { 1500 }
      interval { "month" }
      stripe_id { STRIPE_TEST_PLAN_BASIC_YEAR_ID }
      association product, :pro
    end

    trait :pro_annual do
      name { "Pro Annual" }
      amount { 16500 }
      interval { "year" }
      stripe_id { STRIPE_TEST_PLAN_BASIC_YEAR_ID }
      association product, :pro
    end
  end
end
