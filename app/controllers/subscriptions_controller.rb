class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # NOTE This isn't a controller for a typical model. Subscriptions live in Stripe.
  # We use the columns on the user to know a users current subscription status.

  # GET '/billing'
  def show
    redirect_to subscribe_path unless current_user_subscribed?
    # customer = Stripe::Customer.retrieve(current_user.stripe_id)
  end

  # Serves the form to create a new subsciption.
  # That form hits SubscriptionsController#create below.
  # GET '/subscribe'
  def new
  end

  # TODO this makes requests to Stripe that could fail
  # Catch and handle them.
  # POST /subscriptions
  def create
    customer = if current_user.stripe_id?
                 Stripe::Customer.retrieve(current_user.stripe_id)
               else
                 Stripe::Customer.create(email: current_user.email)
               end

    begin
      # Change this to a selected plan if you have more than 1
      plan = Stripe::Plan.list(limit: 1).first
      subscription = customer.subscriptions.create( source: params[:stripeToken], plan: plan.id)

      options = {
        stripe_id: customer.id,
        stripe_subscription_id: subscription.id,
        role: :user
      }

      # Only update the card on file if we're adding a new one
      options.merge!(
        card_last4: params[:card_last4],
        card_exp_month: params[:card_exp_month],
        card_exp_year: params[:card_exp_year],
        card_type: params[:card_brand]
      ) if params[:card_last4]

      current_user.update(options)
    rescue => e
      puts "Log this error! #{e.inspect}"
    end

    redirect_to root_path
  end

  def destroy
    customer = Stripe::Customer.retrieve(current_user.stripe_id)
    customer.subscriptions.retrieve(current_user.stripe_subscription_id).delete
    current_user.update(stripe_subscription_id: nil)

    redirect_to root_path, notice: "Your subscription has been canceled."
  end
end
