FactoryBot.define do
  factory :invoice do
    association :user
    stripe_id 'asdf'
    amount 900
    currency 'usd'
    number 'd1a9e076f5-0001'
    paid_at '2018-01-28 22:50:26'
    lines [
      {
        "id": "sub_CDqg88OBfqx8Fb",
        "object": "line_item",
        "amount": 0,
        "currency": "usd",
        "description": "1x Pro",
        "discountable": false,
        "livemode": false,
        "metadata": {},
        "period": {
          "start": 1517179826,
          "end": 1518389426},
          "plan": {
            "id": "dcf18e9e-d1bb-4a35-ba31-02478e9d8989",
            "object": "plan",
            "amount": 1500,
            "created": 1517179573,
            "currency": "usd",
            "interval": "month",
            "interval_count": 1,
            "livemode": false,
            "metadata": {},
            "name": "Pro",
            "statement_descriptor": nil,
            "trial_period_days": 14
          },
          "proration": false,
          "quantity": 1,
          "subscription": nil,
          "subscription_item": "si_CDqgCufS4FKS9E",
          "type": "subscription"
        }
      ]
  end
end
