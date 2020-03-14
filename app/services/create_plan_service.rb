# frozen_string_literal: true

class CreatePlanService
  def initialize(plan_model)
    @plan_model = plan_model
  end

  def call
    stripe_plan = nil
    stripe_plan_attrs = {
      product: {
        name: @plan_model.name
      },
      id: @plan_model.name.downcase.tr(' ', '-'),
      amount: @plan_model.amount,
      interval: @plan_model.interval,
      currency: @plan_model.currency,
      trial_period_days: TRIAL_PERIOD_DAYS
    }
    StripeLogger.info "Creating Plan/Product: #{stripe_plan_attrs}"
    begin
      stripe_plan = Stripe::Plan.create stripe_plan_attrs
    rescue Stripe::InvalidRequestError => e
      StripeLogger.error "Error creating plan #{@plan_model.name}: #{e}"
    end

    # Don't hit the DB here as this is performed in before_create
    @plan_model.stripe_id = stripe_plan.id if stripe_plan.present?
  end
end
