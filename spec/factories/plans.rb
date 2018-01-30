FactoryBot.define do
  factory :plan do
    name 'World Domination'
    amount 100000
    interval 'month'
    currency 'usd'
    initialize_with { Plan.where(name: name).first_or_initialize }
  end
end
