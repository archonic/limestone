# frozen_string_literal: true

# Manages all calls to Stripe pertaining to subscriptions
class SubscriptionService
  def initialize(user, plan)
    @user = user
    @user.processor = "stripe"
    @plan = plan
    raise "Plan #{plan.name}<#{plan.id}> is not active!" if !@plan.active?
  end

  def swap_plan!
    stripe_call do
      @user.update(plan_id: @plan.id) if @user.sub.swap(@plan.try(:stripe_id))
    end
  end

  # Subscriptions are created when users complete the registration form.
  def create_subscription!
    subscription, local_product = nil
    begin
      local_product = @plan.try(:product)
    rescue ActiveRecord::RecordNotFound => e
      StripeLogger.error e.message
    end
    raise "Local Product not present on #{@plan.name}<#{@plan.id}>." if local_product.nil?

    stripe_call do
      stripe_plan = Stripe::Plan.retrieve(@plan.stripe_id)
      subscription = @user.subscribe(name: local_product.name, plan: stripe_plan.id)
    end
    subscription
  end

  def destroy_subscription
    stripe_call do
      @user.sub.cancel
    end
  end

  private
    def stripe_call(&block)
      stripe_success = false
      begin
        yield if block
        stripe_success = true
      # https://stripe.com/docs/api?lang=ruby#errors
      rescue  Stripe::CardError,
              Stripe::InvalidRequestError,
              Stripe::RateLimitError,
              Stripe::InvalidRequestError,
              Stripe::AuthenticationError,
              Stripe::APIConnectionError,
              Stripe::StripeError => e
        StripeLogger.error(e.json_body.try(:[], :error))
      end
      stripe_success
    end
end
