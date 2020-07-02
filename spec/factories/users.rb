# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email {  Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { 5.minutes.ago }
    trial_ends_at { 1.hour.from_now }
    association :plan
    initialize_with { User.where(email: email).first_or_initialize }

    trait :admin do
      admin { true }
    end
    trait :pro do
      association :product, :pro
    end
    trait :trial_expired do
      trial_ends_at { 1.hour.ago }
    end
  end
end
