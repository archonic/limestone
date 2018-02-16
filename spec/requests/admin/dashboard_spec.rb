require 'rails_helper'

RSpec.describe 'Administrate Dashboards', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user, :trialing) }

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

      describe 'impersonate' do
        it 'allows impersonation of users' do
          post impersonate_admin_user_path(user.id)
          expect(response).to have_http_status(:redirect)
          expect(flash.any?).to eq false
        end
      end

      describe 'stop_impersonating' do
        it 'allows stop impersonating' do
          get admin_stop_impersonating_path
          expect(response).to have_http_status(:redirect)
          expect(flash.any?).to eq false
        end
      end
    end

    describe InvoiceDashboard do
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

    describe InvoiceDashboard do
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
