class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :check_access, only: :show

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.
  # We use the columns on the user to know a users current subscription status.

  # GET '/billing'
  def show
    @plans = Plan.all
    redirect_to subscribe_path unless current_user.subscribed?
  end

  # GET '/subscribe'
  def new
    redirect_to billing_path if current_user.subscribed?
  end

  # PATCH /subscriptions
  def update
    if SubscriptionService.new(current_user, params).update_subscription
      redirect_to billing_path, flash: { success: 'Subscription updated! If this change alters your abilities, please allow a moment for us to update them.' }
    else
      redirect_to subscribe_path, flash: { error: 'There was an error updating your subscription :(' }
    end
  end
end
