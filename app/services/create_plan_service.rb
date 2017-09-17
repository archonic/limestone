class CreatePlanService
  def call
    begin
      p1 = Stripe::Plan.retrieve('Basic')
    rescue
      p1 = nil
    end
    
    Stripe::Plan.create(
      name: "Basic",
      amount: 900,
      interval: 'month',
      currency: 'usd',
      trial_period_days: 14,
      id: SecureRandom.uuid) unless p1.present?
  end
end
