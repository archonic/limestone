require 'rails_helper'

RSpec.describe 'Administrate Dashboards', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user, :user) }


  context 'as admin' do
    before { sign_in admin }

    describe UserDashboard do
      subject do
        get admin_users_path
        response
      end

      it 'allows admins to access /admin' do
        expect(subject).to have_http_status(:success)
      end
    end

    describe ChargeDashboard do
      subject do
        get admin_users_path
        response
      end

      it 'allows admins to access /admin' do
        expect(subject).to have_http_status(:success)
      end
    end
  end

  context 'as user' do
    before { sign_in user }

    describe UserDashboard do
      subject do
        get admin_users_path
        response
      end

      it 'rejects user with permission denied' do
        expect(subject).to redirect_to root_path
        expect(flash[:alert]).to eq 'Not authorized'
      end
    end

    describe ChargeDashboard do
      subject do
        get admin_users_path
        response
      end

      it 'rejects user with permission denied' do
        expect(subject).to redirect_to root_path
        expect(flash[:alert]).to eq 'Not authorized'
      end
    end
  end
end
