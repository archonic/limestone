# frozen_string_literal: true

# Manages all calls to Stripe pertaining to subscriptions
class SubscriptionService
  def initialize(current_user, params)
    @user = current_user
    @params = params
  end

  # Subscriptions are created when users complete the registration form.
  def create_subscription
    subscription = nil
    @user.processor = "stripe"
    stripe_call do
      local_product = Product.active.find(@params[:user][:product_id])
      local_plan = local_product.plans.active.find(@params[:user][:plan_id])
      return false if local_product.nil?
      stripe_plan = Stripe::Plan.retrieve(local_plan.stripe_id)
      @user.card_token = @params[:stripeToken]
      # NOTE you need name to look up with subscribe? and on_trial_or_subscribed?
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
