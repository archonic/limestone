# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :request do
  describe 'pricing' do
    subject do
      get pricing_path
      response
    end

    it 'renders' do
      expect(subject).to have_http_status(:success)
    end
  end

  describe 'about' do
    subject do
      get about_path
      response
    end

    it 'renders' do
      expect(subject).to have_http_status(:success)
    end
  end

  describe 'cancelled' do
    subject do
      get cancelled_path
      response
    end

    it 'renders' do
      expect(subject).to have_http_status(:success)
    end
  end

  describe 'pro' do
    subject do
      get pro_path
      response
    end

    context 'logged out' do
      it 'denies access at routes level' do
        expect{ subject }.to raise_error(ActionController::RoutingError)
      end
    end

    context 'logged in as basic user' do
      let(:user) { create(:user, :subscribed_basic) }
      before { sign_in user }

      it 'denies access at the controller level' do
        expect(subject).to redirect_to(billing_path)
        expect(flash[:warning]).to match /Upgrade to the Pro plan/
      end
    end

    context 'logged in as pro user' do
      let(:user) { create(:user, :subscribed_pro) }
      before { sign_in user }

      it 'renders' do
        expect(subject).to have_http_status(:success)
      end
    end
  end
end
