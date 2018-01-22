FactoryBot.define do
  factory :user do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    email {  FFaker::Internet.email }
    password 'password'
    password_confirmation 'password'
    initialize_with { User.where(email: email).first_or_initialize }
  end
end
