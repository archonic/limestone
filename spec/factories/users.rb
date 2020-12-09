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

    after(:create) do |user|
      user.processor = "stripe"
      user.subscribe(name: user.product.name, plan: user.plan.stripe_id)
    end

    trait :admin do
      admin { true }
    end

    trait :pro do
      association :product, :pro
    end

    trait :trial_expired do
      trial_ends_at { 1.hour.ago }
    end

    trait :subscribed do
      card_last4 { "4242" }
      card_type { "Visa" }
      card_exp_month { "06" }
      card_exp_year { "2025" }
      trial_ends_at { nil }

      after(:create) do |user|
        # A user must enter their card to transition from trial to active subscription.
        payment_method_id = Stripe::PaymentMethod.create({
          type: "card",
            card: {
              number: "4242424242424242",
              exp_month: 6,
              exp_year: 2025,
              cvc: "123",
            },
          }).id
        user.update_card(payment_method_id)
        # Simulate ending trial and recieving a Stripe webhook
        user.sub.update(
          status: "active",
          trial_ends_at: nil,
          ends_at: 30.days.from_now
        )
      end
    end

    trait :avatared do
      avatar { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/files/money_sloth.png") }
    end
  end
end
