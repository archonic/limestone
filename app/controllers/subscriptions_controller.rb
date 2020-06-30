# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :check_access, only: :show

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.

  # GET '/billing'
  def show
    @plans = Plan.active.all.select(:id, :name)
    redirect_to subscribe_path unless current_user.subscribed_to_any?
  end

  # GET '/subscribe'
  def new
    redirect_to billing_path if current_user.subscribed_to_any?
  end

  # PATCH /subscriptions
  def update
    current_user.processor = "stripe"
    success = if params[:plan_id].present?
      stripe_plan_id = Plan.find(params[:plan_id]).try(:stripe_id)
      current_user.get_subscription.swap(stripe_plan_id)
      current_user.update(plan_id: params[:plan_id])
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
