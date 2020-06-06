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
    stripe_call do
      local_plan = Product.active.find(@params[:user][:product_id])
      return false if local_plan.nil?
      stripe_product = Stripe::Product.retrieve(local_plan.stripe_id)
      # If the plan has a trial time, it does not need a stripe token to create a subscription
      # We assume you have a trial time > 0. Otherwise there will be 2 customers created for
      # each subscribed customer. One at registration and another when subscribing.
      subscription = customer.subscriptions.create(
        source: @params[:stripeToken],
        plan: stripe_product.id
      )
    end
    return false if subscription.nil?

    user_attributes_to_update = {
      stripe_id: customer.id,
      stripe_subscription_id: subscription.id
    }
    assign_card_details(user_attributes_to_update, @params)
    @user.update(user_attributes_to_update)
  end

  # Fires when users subscribe (/subscribe), update their card (/billing) and switch plans.
  def update_subscription
    success = stripe_call do
      customer = Stripe::Customer.retrieve(@user.stripe_id)
      subscription = customer.subscriptions.retrieve(@user.stripe_subscription_id)
      subscription.source = @params[:stripeToken] if @params[:stripeToken]
      # Update plan if one is provided, otherwise use user's existing plan
      # TODO providing product_id is untested
      plan_stripe_id = @params[:product_id] ? Product.find(@params[:product_id]).stripe_id : @user.plan.stripe_id
      subscription.items = [{
        id: subscription.items.data[0].id,
        plan: plan_stripe_id
      }]
      subscription.save
    end
    return false unless success
    user_attributes_to_update = {}
    # This is updated by the stripe webhook customer.updated
    # But we can update it here for a faster optimistic 'response'
    assign_card_details(user_attributes_to_update, @params)
    user_attributes_to_update[:product_id] = @params[:product_id].to_i if @params[:product_id]
    @user.update(user_attributes_to_update) if user_attributes_to_update.any?
    return true if success
  end

  def destroy_subscription
    stripe_call do
      customer.subscriptions.retrieve(@user.stripe_subscription_id).delete
      @user.update(stripe_subscription_id: nil)
    end
  end

  private
    def customer
      @customer ||= if @user.stripe_id?
        Stripe::Customer.retrieve(@user.stripe_id)
      else
        Stripe::Customer.create(email: @user.email)
      end
    end

    def assign_card_details(user_attributes_to_update, params)
      return unless params[:card_last4] && params[:stripeToken]
      user_attributes_to_update.merge!(
        card_last4: params[:card_last4],
        card_exp_month: params[:card_exp_month],
        card_exp_year: params[:card_exp_year],
        card_type: params[:card_brand]
      )
    end

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
