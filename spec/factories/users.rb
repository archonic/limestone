# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email {  Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    association :plan
    initialize_with { User.where(email: email).first_or_initialize }
    stripe_id { 'asdf' } # registration creates subscription on trial creation

    trait :admin do
      role { :admin }
    end
    trait :trialing do
      role { :basic }
      trialing { true }
    end
    trait :subscribed do
      role { :basic }
      trialing { false }
      stripe_subscription_id { 'test_su_2' }
      card_last4 { '4242' }
    end
    trait :pro do
      role { :pro }
      trialing { false }
      stripe_subscription_id { 'test_su_2' }
    end
    trait :removed do
      role { :removed }
    end
    trait :expired do
      role { :basic }
      trialing { true }
      current_period_end { 1.hour.ago }
    end
  end
end
