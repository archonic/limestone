# frozen_string_literal: true

class StripePlanService
  def initialize(plan_model)
    @plan_model = plan_model
  end

  def create
    # Don't contact Stripe if we already have a stripe_id
    return false if @plan_model.product.stripe_id.blank? || @plan_model.stripe_id.present?

    stripe_plan = nil
    stripe_plan_attrs = {
      product: @plan_model.product.stripe_id,
      amount: @plan_model.amount,
      interval: @plan_model.interval,
      currency: @plan_model.currency,
      trial_period_days: TRIAL_PERIOD_DAYS
    }
    p "Creating Plan: #{stripe_plan_attrs}"
    begin
      stripe_plan = Stripe::Plan.create stripe_plan_attrs
    rescue Stripe::InvalidRequestError => e
      p "Error creating Plan #{@plan_model.name}: #{ e.json_body[:error]}"
    end

    @plan_model.update(stripe_id: stripe_plan.id) if stripe_plan.present?
  end
end
