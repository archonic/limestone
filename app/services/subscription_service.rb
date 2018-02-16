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
      plan = Stripe::Plan.list(limit: @params[:plan_id]).first
      # If the plan has a trial time, it does not need a stripe token to create a subscription
      # We assume you have a trial time > 0. Otherwise there will be 2 customers created for
      # each subscribed customer. One at registration and another when subscribing.
      subscription = customer.subscriptions.create(
        source: @params[:stripeToken],
        plan: plan.id
      )
    end
    return false if subscription.nil?

    user_attributes_to_update = {
      stripe_id: customer.id,
      stripe_subscription_id: subscription.id
    }

    # Only update the card on file if we're adding a new one
    # Limestone doesn't use this because we don't ask for a card upon registration
    # but you could add the card form to the registration form
    user_attributes_to_update.merge!(
      card_last4: @params[:card_last4],
      card_exp_month: @params[:card_exp_month],
      card_exp_year: @params[:card_exp_year],
      card_type: @params[:card_brand]
    ) if @params[:card_last4]

    @user.update(user_attributes_to_update)
  end

  # Fires when users subscribe (/subscribe), update their card (/billing) and switch plans.
  def update_subscription
    success = stripe_call do
      customer = Stripe::Customer.retrieve(@user.stripe_id)
      subscription = customer.subscriptions.retrieve(@user.stripe_subscription_id)
      subscription.source = @params[:stripeToken] if @params[:stripeToken]
      # Update plan if one is provided, otherwise use user's existing plan
      plan_stripe_id = if @params[:plan_id]
        Plan.find(@params[:plan_id]).stripe_id
      else
        @user.plan.stripe_id
      end
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
    user_attributes_to_update.merge!(
      card_last4: @params[:card_last4],
      card_exp_month: @params[:card_exp_month],
      card_exp_year: @params[:card_exp_year],
      card_type: @params[:card_brand]
    ) if @params[:card_last4] && @params[:stripeToken]
    user_attributes_to_update.merge!(
      plan_id: @params[:plan_id].to_i
    ) if @params[:plan_id]
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

  def stripe_call(&block)
    stripe_success = false
    begin
      block.call
      stripe_success = true
    # https://stripe.com/docs/api?lang=ruby#errors
    rescue Stripe::CardError => e
      StripeLogger.error(e.json_body[:error])
    rescue Stripe::RateLimitError => e
      StripeLogger.error 'Too many requests made to the API too quickly.'
    rescue Stripe::InvalidRequestError => e
      StripeLogger.error 'Invalid parameters were supplied to Stripe\'s API.'
    rescue Stripe::AuthenticationError => e
      StripeLogger.error 'Authentication with Stripe\'s API failed. Maybe you changed API keys recently.'
    rescue Stripe::APIConnectionError => e
      StripeLogger.error 'Network communication with Stripe failed.'
    rescue Stripe::StripeError => e
      StripeLogger.error 'Genric Stripe error.'
    end
    return stripe_success
  end
end
