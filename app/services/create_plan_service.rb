class CreatePlanService
  def self.call
    begin
      p1 = Stripe::Plan.retrieve('Basic')
    rescue
      p1 = nil
    end

    return if p1.present?

    Stripe::Plan.create(
      name: 'Basic',
      amount: 900,
      interval: 'month',
      currency: 'usd',
      trial_period_days: Rails.application.secrets.trial_period_days,
      id: SecureRandom.uuid
    )
  end
end
