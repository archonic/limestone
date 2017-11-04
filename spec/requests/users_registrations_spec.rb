require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :request do
  let(:user) { create(:user_subscribed) }

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

  end
end
