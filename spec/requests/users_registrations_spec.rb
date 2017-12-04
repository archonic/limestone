require 'rails_helper'
require 'stripe_mock'

RSpec.describe Users::RegistrationsController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:user) { create(:user_subscribed) }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'basic', amount: 900)
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

    subject do
      post '/profile', params: { user: user_params }
      response
    end

    it 'creates a subscribed user' do
      subject
      user = User.find_by(email: user_params[:email])
      expect(user).to be_present
      expect(user.subscribed?).to be true
    end

    it 'populates subscription data' do
      subject
      user = User.find_by(email: user_params[:email])
      expect(user.stripe_id).to be_present
      expect(user.stripe_subscription_id).to be_present
    end

    it 'redirects to dashboard' do
      expect(subject).to redirect_to(dashboard_path)
    end
  end

  describe 'DELETE /profile' do
    let(:user) { create(:user_subscribed) }
    let!(:user_id) { user.id }
    before do
      sign_in user
    end

    subject do
      delete user_registration_path
      response
    end

    it 'destroys the user account' do
      expect(user.reload).to eq User.find(user_id)
      subject
      expect { user.reload }.to raise_exception(ActiveRecord::RecordNotFound)
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
