class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.
  # We use the columns on the user to know a users current subscription status.

  # GET '/billing'
  def show
    redirect_to subscribe_path unless current_user_subscribed?
    # customer = Stripe::Customer.retrieve(current_user.stripe_id)
  end

  # GET '/subscribe'
  def new
  end

  # POST /subscriptions
  def create
    @@subscription_service = SubscriptionService.new(current_user, params)
    @@subscription_service.create_subscription
    redirect_to root_path
  end
end
