class CreatePlanService
  def initialize(plan_model)
    @plan_model = plan_model
  end

  def call
    stripe_plan = nil
    begin
      stripe_plan = Stripe::Plan.create(
        id: SecureRandom.uuid,
        name: @plan_model.name,
        amount: @plan_model.amount,
        interval: @plan_model.interval,
        currency: @plan_model.currency,
        trial_period_days: $trial_period_days
      )
    rescue Stripe::InvalidRequestError => e
      StripeLogger.error "Error creating plan #{@plan_model.name}: #{e}"
      raise ActiveRecord::RecordInvalid, "Error creating plan #{@plan_model.name} in Stripe: #{e}"
    end

    # Don't hit the DB here as this is performed in before_create
    @plan_model.stripe_id = stripe_plan.id if stripe_plan.present?
  end
end
