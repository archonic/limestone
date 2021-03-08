# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :check_access, only: :show

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.

  # GET '/billing'
  def show
    redirect_to subscribe_path unless current_user.sub_active?

    @plans = Plan.active.all.select(:id, :name)
  end

  # GET '/subscribe'
  def new
    redirect_to billing_path if current_user.sub_active?
  end

  # PATCH /subscriptions
  def update
    current_user.processor = "stripe"
    success = if params[:plan_id].present?
      SubscriptionService.new(current_user, params[:plan_id]).swap_plan!
    elsif params[:payment_method_id].present?
      current_user.update_card(params[:payment_method_id])
    end
    if success
      redirect_to billing_path,
        flash: { success: "Subscription updated!" }
    else
      redirect_to subscribe_path,
        flash: { error: "There was an error updating your subscription :(" }
    end
  end
end
