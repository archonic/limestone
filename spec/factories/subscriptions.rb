# # frozen_string_literal: true

FactoryBot.define do
  # NOTE Not used! (yet)
  factory :subscription, class: Pay::Subscription do
    association :owner, factory: :user
    name { "[test] Basic" }
    processor { "stripe" }
    # See subscriptions_spec.rb for example of how to create a valid subscription ID
    processor_id { "sub_xxx" }
    processor_plan { "plan_xxx" }
    quantity { 1 }
    trial_ends_at { TRIAL_PERIOD_DAYS.days.from_now }
    ends_at { nil }
    created_at { 1.minute.ago }
    updated_at { 1.minute.ago }
    status { "active" }
    prorate { true }

    trait :pro do
      name { "[test] Pro" }
      processor_plan {
        {
          id: STRIPE_TEST_PLAN_PRO_MONTH_ID,
          object: "plan",
          active: true,
          aggregate_usage: nil,
          amount: 1500,
          amount_decimal: 1500,
          billing_scheme: "per_unit",
          created: 1592584799,
          currency: "usd",
          interval: "month",
          interval_count: 1,
          livemode: false,
          metadata: {},
          nickname: nil,
          product: STRIPE_TEST_PRODUCT_PRO_ID,
          tiers: nil,
          tiers_mode: nil,
          transform_usage: nil,
          trial_period_days: TRIAL_PERIOD_DAYS,
          usage_type: "licensed"
        }.to_json
      }
    end

    trait :trialing do
      status { "trialing" }
    end
    trait :past_due do
      status { "past_due" }
    end
    trait :canceled do
      status { "canceled" }
    end
    trait :unpaid do
      status { "unpaid" }
    end
  end
end
