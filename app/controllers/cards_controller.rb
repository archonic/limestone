class CardsController < ApplicationController
  before_action :authenticate_user!
  # verify that user is subscribed

  def update
    @@subscription_service = SubscriptionService.new(current_user, params)
    if @@subscription_service.update_subscription
      redirect_to billing_path, notice: "Successfully updated your card"
    else
      redirect_path = current_user.subscribed? ? billing_path : subscribe_path
      redirect_to redirect_path, flash: { error: 'There was an error updating your subscription :(' }
    end
  end
end
