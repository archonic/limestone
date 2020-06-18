# frozen_string_literal: true

require "rails_helper"

RSpec.describe InvoicesController, type: :request do
  # before do
  #   stripe_helper.create_plan(
  #     id: "example-plan-id",
  #     name: "World Domination",
  #     amount: 100_000,
  #     trial_period_days: TRIAL_PERIOD_DAYS
  #   )
  # end
  let(:mock_customer) { Stripe::Customer.create }
  let(:mock_subscription) do
    mock_customer.subscriptions.create(
      plan: "example-plan-id"
    )
  end
  let(:user_subscribed) do
    create(
      :user,
      :subscribed_basic,
      stripe_id:
      mock_customer.id,
      stripe_subscription_id: mock_subscription.id
    )
  end
  let(:user) { create(:user, :trialing) }
  let(:invoice) { create(:invoice) }

  describe "GET /invoices/:id" do
    subject do
      get invoice_path(invoice.id, format: :pdf)
      response
    end

    context "as a subscribed user" do
      before { sign_in user_subscribed }

      it "serves an invoice PDF" do
        expect(subject).to have_http_status(:success)
        expect(subject.header["Content-Type"]).to eq "application/pdf"
      end
    end
  end
end
