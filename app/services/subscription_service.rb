# frozen_string_literal: true

# Manages all calls to Stripe pertaining to subscriptions
class SubscriptionService
  def initialize(current_user, plan_id = nil)
    @user = current_user
    @plan_id = plan_id
    @user.processor = "stripe"
  end

  # Subscriptions are created when users complete the registration form.
  def create_subscription!
    subscription, local_product, local_plan = nil
    begin
      local_plan = Plan.active.find(@plan_id)
      local_product = local_plan.product
    rescue ActiveRecord::RecordNotFound => e
      StripeLogger.error e.message
    end
    raise "Local Plan or Product not present." if local_product.nil? || local_plan.nil?
    stripe_call do
      stripe_plan = Stripe::Plan.retrieve(local_plan.stripe_id)
      subscription = @user.subscribe(name: local_product.name, plan: stripe_plan.id)
    end
    subscription
  end

  def destroy_subscription
    stripe_call do
      @user.subscription.cancel
    end
  end

  private
    def stripe_call(&block)
      stripe_success = false
      begin
        yield if block
        stripe_success = true
      # https://stripe.com/docs/api?lang=ruby#errors
      rescue Stripe::CardError => e
        StripeLogger.error(e.json_body[:error])
      rescue Stripe::RateLimitError
        StripeLogger.error "Too many requests made to the API too quickly."
      rescue Stripe::InvalidRequestError
        StripeLogger.error "Invalid parameters were supplied to Stripe's API."
      rescue Stripe::AuthenticationError
        StripeLogger.error("Authentication with Stripe's API failed. Maybe you changed API keys recently. sdfgdfg")
      rescue Stripe::APIConnectionError
        StripeLogger.error "Network communication with Stripe failed."
      rescue Stripe::StripeError
        StripeLogger.error "Genric Stripe error."
      end
      stripe_success
    end
end
