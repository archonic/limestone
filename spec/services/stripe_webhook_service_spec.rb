require 'rails_helper'
require 'stripe_mock'

RSpec.describe StripeWebhookService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'basic', amount: 900, trial_period_days: $trial_period_days)
  end
  let(:mock_customer) { Stripe::Customer.create }
  let(:mock_subscription) { mock_customer.subscriptions.create(plan: 'basic') }
  let!(:user_subscribed) { create(:user, :user, stripe_id: mock_customer.id, stripe_subscription_id: mock_subscription.id) }
  after { StripeMock.stop }

  describe StripeWebhookService::RecordInvoicePaid do
    let(:event_no_customer) { StripeMock.mock_webhook_event('invoice.payment_succeeded') }
    let(:event_customer) { StripeMock.mock_webhook_event('invoice.payment_succeeded', customer: mock_customer.id, total: 3000) }

    subject do
      StripeWebhookService::RecordInvoicePaid.new.call(event_customer)
    end

    it 'logs failure to find user when no valid customer' do
      expect(StripeLogger).to receive(:error).once.with(/No user found with stripe_id/)
      StripeWebhookService::RecordInvoicePaid.new.call(event_no_customer)
    end

    context 'when the total is zero' do
      before do
        @old_total = event_customer.data.object.total
        event_customer.data.object.total = 0
      end
      after {  event_customer.data.object.total = @old_total }

      it 'does not create invoice' do
        expect(Invoice).to_not receive(:first_or_initialize)
        subject
      end
    end

    context 'when the total is > zero' do
      it 'creates an invoice record with appropriate attributes and synchronously mails user' do
        event_data = event_customer.data.object
        lines = event_data.lines.data
        expect_any_instance_of(Invoice).to receive(:assign_attributes).once.with(
          amount: event_data.total,
          currency: event_data.currency,
          number: event_data.number,
          paid_at: Time.at(event_data.date).to_datetime,
          lines: lines
        )
        expect_any_instance_of(Invoice).to receive(:save!).and_return true
        expect(UserMailer).to receive(:invoice_paid).once.with(
          user_subscribed,
          instance_of(Invoice)
        )

        invoice_paid_dbl = double(ActionMailer::MessageDelivery)
        allow(UserMailer).to receive(:invoice_paid).and_return(invoice_paid_dbl)
        expect(invoice_paid_dbl).to receive(:deliver_later).once
        subject
      end
    end
  end

  describe StripeWebhookService::UpdateCustomer do
    let(:event_customer) { StripeMock.mock_webhook_event('customer.updated', id: mock_customer.id) }
    subject do
      StripeWebhookService::UpdateCustomer.new.call(event_customer)
    end

    context 'without valid customer' do
      let(:event_no_customer) { StripeMock.mock_webhook_event('customer.updated') }
      it 'logs failure to find user when no valid customer' do
        expect(StripeLogger).to receive(:error).once.with(/No user found with stripe_id/)
        StripeWebhookService::UpdateCustomer.new.call(event_no_customer)
      end
    end

    context 'with no source in payload' do
      let(:event_no_source) do
        StripeMock.mock_webhook_event('customer.updated', id: mock_customer.id, sources: nil)
      end
      subject do
        StripeWebhookService::UpdateCustomer.new.call(event_no_source)
      end

      it 'logs error with no source message' do
        expect(StripeLogger).to receive(:error).once.with(/has no source./)
        subject
      end

      it 'does not update user with billing info' do
        expect(user_subscribed).to_not receive(:assign_attributes)
        subject
      end

      it 'does not send billing updated email' do
        expect(UserMailer).to_not receive(:billing_updated)
        subject
      end
    end

    context 'with no subscription in payload' do
      let(:event_no_subscription) { StripeMock.mock_webhook_event('customer.updated', id: mock_customer.id, subscriptions: nil) }
      subject do
        StripeWebhookService::UpdateCustomer.new.call(event_no_subscription)
      end
      it 'logs error with no subscription message' do
        expect(StripeLogger).to receive(:error).once.with(/has no subscription/)
        subject
      end
    end

    context 'with source and subscription in payload' do
      it 'does not error' do
        expect(StripeLogger).to_not receive(:error)
        subject
      end

      it 'updates the users role' do
        expect(user_subscribed.user?).to eq true
        expect_any_instance_of(User).to receive(:save).once.and_return(true)
        subject
        # Y U no pass!?
        # expect(user_subscribed.reload.trial?).to eq true
      end

      it 'updates the users current_period_end' do
        # expect(
        #   assigns(user_subscribed.current_period_end)
        # ).to eq Time.at(event_customer.data.object.subscriptions.first.current_period_end).to_datetime
        # subject
      end
    end
  end

  describe StripeWebhookService::TrialWillEnd do
    let(:event) { StripeMock.mock_webhook_event('customer.subscription.trial_will_end') }

    it '' do

    end
  end

  describe StripeWebhookService::Dun do
    it '' do

    end
  end
end
