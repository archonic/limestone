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
      plan = Stripe::Plan.list(limit: 1).first
      # If the plan has a trial time, it does not need a stripe token to create a subscription
      # We assume you have a trial time > 0. Otherwise there will be 2 customers created for
      # each subscribed customer. One at registration and another when subscribing.
      subscription = customer.subscriptions.create(
        source: @params[:stripeToken],
        plan: plan.id
      )
    end
    return false if subscription.nil?

    options = {
      stripe_id: customer.id,
      stripe_subscription_id: subscription.id
    }

    # Only update the card on file if we're adding a new one
    # Limestone doesn't use this because we don't ask for a card upon registration
    # but you could add the card form to the registration form
    options.merge!(
      card_last4: @params[:card_last4],
      card_exp_month: @params[:card_exp_month],
      card_exp_year: @params[:card_exp_year],
      card_type: @params[:card_brand]
    ) if @params[:card_last4]

    @user.update(options)
  end

  # Only used to update source for subscription.
  # This is when users subscribe (/subscribe) and update their card (/billing).
  def update_subscription
    success = stripe_call do
      customer = Stripe::Customer.retrieve(@user.stripe_id)
      subscription = customer.subscriptions.retrieve(@user.stripe_subscription_id)
      subscription.source = @params[:stripeToken]
      subscription.save
    end
    return false unless success
    @user.update(
      card_last4: @params[:card_last4],
      card_exp_month: @params[:card_exp_month],
      card_exp_year: @params[:card_exp_year],
      card_type: @params[:card_brand]
    )
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
      StripeLogger.error 'Invalid paramaters were supplied to Stripe\'s API.'
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
