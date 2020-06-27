# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationsController, type: :request do
  before do
    # Allow public registration before testing it
    Flipper.enable :public_registration
  end

  describe "POST /profile" do
    let!(:product) { create(:product) }
    let!(:plan) { create(:plan, product: product) }

    context "with valid parameters" do
      let(:valid_user_params) do
        {
          email: Faker::Internet.email,
          password: "password",
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          plan_id: plan.id
        }
      end
      let(:user) { User.find_by(email: valid_user_params[:email]) }

      subject do
        post user_registration_path, params: { user: valid_user_params }
        response
      end

      it "creates a user on a trial" do
        subject
        expect(user).to be_present
        expect(user.on_trial_or_subscribed?).to be true
        # False for the wrong reason? check subscribed_to_any?
        expect(user.subscribed?).to be false
      end

      it "populates customer data" do
        subject
        expect(user.customer).to be_present
      end

      it "sets the trial expiration date" do
        subject
        expect(user.trial_ends_at).to be_within(5.minutes).of(14.days.from_now)
      end

      it "redirects to dashboard" do
        expect(subject).to redirect_to dashboard_path
      end
    end

    context "with invalid parameters" do
      # Invalid due to missing last name
      let(:invalid_user_params) do
        {
          email: Faker::Internet.email,
          password: "password",
          first_name: Faker::Name.first_name,
          plan_id: plan.id
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
    let!(:user) { create(:user) }
    let(:subscription) { double(Pay::Subscription) }
    before do
      allow(user).to receive(:subscription) { subscription }
      allow(subscription).to receive(:cancel) { true }
      sign_in user
    end
    subject do
      delete user_registration_path
      response
    end

    context "subscription cancellation succeeds" do
      it "cancels the subscription, and signs out + discards the user" do
        expect(subscription).to receive(:cancel).once
        subject
      end

      it "discards and logs out the user" do
        subject
        expect(user.reload.discarded?).to be true
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
