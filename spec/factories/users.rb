FactoryBot.define do
  factory :user do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    email {  FFaker::Internet.email }
    password 'password'
    password_confirmation 'password'
    initialize_with { User.where(email: email).first_or_initialize }

    trait :admin do
      role :admin
    end
    trait :trial do
      role :trial
    end
    trait :user do
      role :user
    end
    trait :removed do
      role :removed
    end
    trait :expired do
      current_period_end 1.hour.ago
    end
  end
end
