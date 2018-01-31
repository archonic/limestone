require 'rails_helper'
require 'stripe_mock'

RSpec.describe SubscriptionsController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'basic', amount: 900, trial_period_days: $trial_period_days)
  end
  after { StripeMock.stop }
  let(:mock_customer) { Stripe::Customer.create }
  let(:mock_subscription) { mock_customer.subscriptions.create(plan: 'basic') }
  let(:user_trial) { create(:user, :trial) }
  let(:user_subscribed) {
    create(
      :user,
      :user,
      stripe_id: mock_customer.id,
      stripe_subscription_id: mock_subscription.id,
      card_last4: '4242',
      card_exp_month: 12,
      card_exp_year: 2025,
      card_type: 'Visa'
    )
  }

  describe 'GET billing_path' do
    subject do
      get billing_path
      response
    end

    context 'as a trial user' do
      before { sign_in user_trial }

      it 'redirects to subscribe page' do
        expect(subject).to redirect_to subscribe_path
      end
    end

    context 'as a subscribed user' do
      before { sign_in user_subscribed }

      it 'shows card on file' do
        expect(subject).to have_http_status(:success)
        expect(subject.body).to include "Visa **** **** **** 4242"
        expect(subject.body).to include "Expires 12 / 2025"
      end

      it 'shows next payment' do
        expect(subject.body).to include "Your card will be charged #{user_subscribed.plan.cost} on #{user_subscribed.current_period_end.strftime('%A, %B %e, %Y')}"
      end
    end
  end
end
