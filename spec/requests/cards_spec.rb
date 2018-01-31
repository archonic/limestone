require 'rails_helper'
require 'stripe_mock'

RSpec.describe CardsController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'basic', amount: 900, trial_period_days: $trial_period_days)
  end
  after { StripeMock.stop }
  let(:mock_customer) { Stripe::Customer.create }
  let(:mock_subscription) { mock_customer.subscriptions.create(plan: 'basic') }
  let(:user_subscribed) { create(:user, :user, stripe_id: mock_customer.id, stripe_subscription_id: mock_subscription.id) }
  let(:user_trial) { create(:user, :trial) }

  describe 'POST /update-card' do
    subject do
      post update_card_path, params: {
        stripeToken: stripe_helper.generate_card_token,
        card_brand: 'MasterCard',
        card_exp_month: 12,
        card_exp_year: 2024,
        card_last4: 4444
      }
      response
    end

    context 'as a not subscribed user' do
      before { sign_in user_trial }
      it 'redirects to root with access denied' do
        expect(subject).to redirect_to root_path
        expect(flash[:alert]).to match 'Access denied'
      end
    end

    context 'as a subscribed user' do
      before { sign_in user_subscribed }

      context 'with good params' do
        it 'updates the existing subscription' do
          expect(subject).to redirect_to billing_path
          expect(flash[:notice]).to match 'Successfully updated your card'
        end
      end

      context 'with bad params' do
        it 'displays error' do
          post update_card_path, params: {
            card_brand: 'MasterCard',
            card_exp_month: 12,
            card_exp_year: 2024,
            card_last4: 4444
          }
          expect(response).to redirect_to billing_path
          expect(flash[:error]).to match 'There was an error updating your card'
        end
      end
    end
  end
end
