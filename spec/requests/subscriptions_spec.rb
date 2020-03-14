# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe SubscriptionsController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(
      id: "example-plan-id",
      name: "World Domination",
      amount: 100_000,
      trial_period_days: TRIAL_PERIOD_DAYS
    )
  end
  after { StripeMock.stop }
  let(:mock_customer) { Stripe::Customer.create }
  let(:mock_subscription) { mock_customer.subscriptions.create(plan: "example-plan-id") }
  let(:user_trial) { create(:user, :trialing) }
  let(:user_subscribed) {
    create(
      :user,
      :subscribed_basic,
      stripe_id: mock_customer.id,
      stripe_subscription_id: mock_subscription.id,
      card_last4: "4242",
      card_exp_month: 12,
      card_exp_year: 2025,
      card_type: "Visa"
    )
  }

  describe "GET billing_path" do
    subject do
      get billing_path
      response
    end

    context "as a trial user" do
      before { sign_in user_trial }

      it "redirects to subscribe page" do
        expect(subject).to redirect_to subscribe_path
      end
    end

    context "as a subscribed user" do
      before { sign_in user_subscribed }

      it "shows card on file" do
        expect(subject).to have_http_status(:success)
        expect(subject.body).to include "Visa **** **** **** 4242"
        expect(subject.body).to include "Expires 12 / 2025"
      end

      it "shows next payment" do
        expect(subject.body).to include "Your card will be charged"
        expect(subject.body).to include user_subscribed.plan.cost
        expect(subject.body).to include "on #{user_subscribed.current_period_end.strftime('%A, %B %e, %Y')}"
      end
    end
  end

  describe "PATCH /subscriptions" do
    subject do
      patch subscriptions_path, params: {
        stripeToken: stripe_helper.generate_card_token,
        card_brand: "MasterCard",
        card_exp_month: 12,
        card_exp_year: 2024,
        card_last4: 4444
      }
      response
    end

    context "as a not subscribed user" do
      before { sign_in user_trial }
      it "redirects to billing page with access denied" do
        expect(StripeLogger).to receive(:error).once.with("Invalid parameters were supplied to Stripe's API.")
        expect(subject).to redirect_to subscribe_path
        expect(flash[:error]).to match "There was an error updating your subscription"
      end
    end

    context "as a subscribed user" do
      before { sign_in user_subscribed }

      context "with good params" do
        it "updates the existing subscription" do
          expect(subject).to redirect_to billing_path
          expect(flash[:success]).to match "Subscription updated"
        end
      end

      context "with no stripe token and no plan" do
        it "does not update user but reports success" do
          expect(user_subscribed).to_not receive(:update)
          patch subscriptions_path, params: {
            card_brand: "MasterCard",
            card_exp_month: 12,
            card_exp_year: 2024,
            card_last4: 4444
          }
          expect(response).to redirect_to billing_path
          # Although no changes were made, there were no errors.
          # Success response indicates that current data is correct
          expect(flash[:success]).to match "Subscription updated"
        end
      end
    end
  end
end
