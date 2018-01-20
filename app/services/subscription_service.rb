# Manages all calls to Stripe pertaining to subscriptions
class SubscriptionService

  def initialize(current_user, params)
    @user = current_user
    @params = params
  end

  def create_subscription
    stripe_success = false
    begin
      plan = Stripe::Plan.list(limit: 1).first
      subscription = customer.subscriptions.create(
        source: @params[:stripeToken],
        plan: plan.id
      )
      stripe_success = true
    # https://stripe.com/docs/api?lang=ruby#errors
    rescue Stripe::CardError => e
      SubscriptionLogger.error(e.json_body[:error])
    rescue Stripe::RateLimitError => e
      SubscriptionLogger.error 'Too many requests made to the API too quickly.'
    rescue Stripe::InvalidRequestError => e
      SubscriptionLogger.error 'Invalid paramaters were supplied to Stripe\'s API.'
    rescue Stripe::AuthenticationError => e
      SubscriptionLogger.error 'Authentication with Stripe\'s API failed. Maybe you changed API keys recently.'
    rescue Stripe::APIConnectionError => e
      SubscriptionLogger.error 'Network communication with Stripe failed.'
    rescue Stripe::StripeError => e
      SubscriptionLogger.error 'Genric Stripe error.'
    end

    return false unless stripe_success

    options = {
      stripe_id: customer.id,
      stripe_subscription_id: subscription.id,
      role: :user
    }

    # Only update the card on file if we're adding a new one
    options.merge!(
      card_last4: @params[:card_last4],
      card_exp_month: @params[:card_exp_month],
      card_exp_year: @params[:card_exp_year],
      card_type: @params[:card_brand]
    ) if @params[:card_last4]

    @user.update(options)
  end

  def destroy_subscription
    customer.subscriptions.retrieve(current_user.stripe_subscription_id).delete
    current_user.update(stripe_subscription_id: nil)
  end

  private

  def customer
    @customer ||= if @user.stripe_id?
      Stripe::Customer.retrieve(@user.stripe_id)
    else
      Stripe::Customer.create(email: @user.email)
    end
  end
end
