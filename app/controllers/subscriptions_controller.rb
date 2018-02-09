class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.
  # We use the columns on the user to know a users current subscription status.

  # GET '/billing'
  def show
    redirect_to subscribe_path unless current_user_subscribed?
  end

  # GET '/subscribe'
  def new
    redirect_to billing_path if current_user.subscribed?
  end

  # PATCH /subscriptions
  def update
    @@subscription_service = SubscriptionService.new(current_user, params)
    if @@subscription_service.update_subscription
      redirect_to billing_path, flash: { success: 'Your subscription has been updated! If this change alters your role, please allow a moment for us to update it.' }
    else
      redirect_to subscribe_path, flash: { error: 'There was an error updating your subscription :(' }
    end
  end
end
