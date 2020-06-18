# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationsController, type: :request do
  before do
    # Allow public registration before testing it
    Flipper.enable :public_registration
  end

  describe "POST /profile" do
    context "with valid parameters" do
      let(:product) { create(:product) }
      let(:valid_user_params) do
        {
          email: Faker::Internet.email,
          password: "password",
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          product_id: product.id,
          plan_id: product.plan_id
        }
      end
      let(:user) { User.find_by(email: valid_user_params[:email]) }

      subject do
        post user_registration_path, params: { user: valid_user_params }
        response
      end

      it "creates a user with a stripe subscription" do
        subject
        expect(user).to be_present
        expect(user.stripe_id?).to be_present
      end

      it "populates subscription data" do
        subject
        expect(user.stripe_id).to be_present
        expect(user.stripe_subscription_id).to be_present
      end

      it "sets the trial expiration date" do
        subject
        expect(user.current_period_end).to be_present
        expect(user.current_period_end).to be_within(1).of(Time.current + 14.days)
      end

      it "redirects to dashboard" do
        expect(subject).to redirect_to dashboard_path
      end
    end

    context "with invalid parameters" do
      let(:invalid_user_params) do
        {
          email: Faker::Internet.email,
          password: "password",
          first_name: Faker::Name.first_name
        }
      end
      let(:user) { User.find_by(email: invalid_user_params[:email]) }

      subject do
        post user_registration_path, params: { user: invalid_user_params }
        response
      end

      it "does not create a user" do
        subject
        expect(user).to_not be_present
      end

      it "redirects to registration" do
        expect(subject).to have_http_status(:success)
        expect(subject).to render_template :new
      end
    end
  end

  describe "DELETE /profile" do
    let(:mock_customer) { Stripe::Customer.create }
    let(:mock_subscription) do
      mock_customer.subscriptions.create(
        plan: "example-plan-id"
      )
    end
    let!(:user_subscribed) do
      create(
        :user,
        :subscribed_basic,
        stripe_id: mock_customer.id,
        stripe_subscription_id: mock_subscription.id
      )
    end
    before do
      sign_in user_subscribed
    end
    subject do
      delete user_registration_path
      response
    end

    context "subscription cancellation succeeds" do
      it "discards the user account" do
        subject
        expect(user_subscribed.reload.discarded?).to be true
      end

      it "signs the user out" do
        subject
        expect(controller.signed_in?).to be false
      end

      it "redirects to cancelled path" do
        expect(subject).to redirect_to cancelled_path
      end
    end

    context "subscription cancellation fails" do
      before do
        allow_any_instance_of(SubscriptionService).to receive(:stripe_call).and_return(false)
      end

      it "notifies user of failure" do
        subject
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq I18n.t("devise.registrations.user.stripe_communication_error")
      end

      it "redirects to edit registration path" do
        expect(subject).to redirect_to edit_user_registration_path
      end
    end
  end
end
