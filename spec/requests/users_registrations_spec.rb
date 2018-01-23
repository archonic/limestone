require 'rails_helper'
require 'stripe_mock'

RSpec.describe Users::RegistrationsController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:user) { create(:user_subscribed) }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'basic', amount: 900, trial_period_days: $trial_period_days)
  end
  after { StripeMock.stop }

  describe 'POST /profile' do
    let(:user_params) do
      {
         email: FFaker::Internet.email,
         password: 'password',
         first_name: FFaker::Name.first_name,
         last_name: FFaker::Name.last_name
      }
    end
    let(:user) { User.find_by(email: user_params[:email]) }

    subject do
      post user_registration_path, params: { user: user_params }
      response
    end

    it 'creates a subscribed user' do
      subject
      expect(user).to be_present
      expect(user.subscribed?).to be true
    end

    it 'populates subscription data' do
      subject
      expect(user.stripe_id).to be_present
      expect(user.stripe_subscription_id).to be_present
    end

    it 'sets the trial expiration date' do
      subject
      expect(user.trial_ends_at).to be_present
      expect(user.trial_ends_at).to be_within(1).of(Time.current + 14.days)
    end

    it 'redirects to dashboard' do
      expect(subject).to redirect_to(dashboard_path)
    end
  end

  describe 'DELETE /profile' do
    let(:mock_customer) { Stripe::Customer.create }
    let(:mock_subscription) { mock_customer.subscriptions.create(plan: 'basic') }
    let!(:user) { create(:user, stripe_id: mock_customer.id, stripe_subscription_id: mock_subscription.id) }
    before do
      sign_in user
    end

    subject do
      delete user_registration_path
      response
    end

    it 'discards the user account' do
      subject
      expect(user.reload.discarded?).to be true
    end

    it 'marks the user role as removed' do
      subject
      expect(user.reload.role).to eq 'removed'
    end

    it 'signs the user out' do
      subject
      expect(controller.signed_in?).to be false
    end

    it 'redirects to cancelled path' do
      expect(subject).to redirect_to(cancelled_path)
    end
  end
end
