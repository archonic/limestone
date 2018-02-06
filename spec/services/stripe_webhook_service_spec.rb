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
      it 'creates an invoice record with appropriate attributes and asynchronously mails user' do
        event_data = event_customer.data.object
        lines = event_data.lines.data
        expect_any_instance_of(Invoice).to receive(:assign_attributes).once.with(
          amount: event_data.total,
          currency: event_data.currency,
          number: event_data.number,
          paid_at: Time.at(event_data.date).to_datetime,
          lines: lines
        )
        expect_any_instance_of(Invoice).to receive(:save).and_return true
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

      it 'updates and commits user attributes appropriately' do
        expect(user_subscribed.user?).to eq true
        expect(User).to receive(:find_by).with(stripe_id: event_customer.data.object.id).and_return(user_subscribed)
        source = event_customer.data.object.sources.first
        subscription = event_customer.data.object.subscriptions.first
        expect(user_subscribed).to receive(:assign_attributes).once.with(
          card_last4: source.last4,
          card_type: source.brand,
          card_exp_month: source.exp_month,
          card_exp_year: source.exp_year,
          role: 'trial',
          current_period_end: Time.at(subscription.current_period_end).to_datetime
        )
        expect(user_subscribed).to receive(:save).once.and_return(true)
        subject
      end

      it 'asynchronously mails the user with billing updated' do
        billing_updated_dbl = double(ActionMailer::MessageDelivery)
        allow(UserMailer).to receive(:billing_updated).with(
          user_subscribed
        ).and_return(billing_updated_dbl)
        expect(billing_updated_dbl).to receive(:deliver_later).once
        subject
      end
    end
  end

  describe StripeWebhookService::TrialWillEnd do
    let(:event_trial_will_end) {
      StripeMock.mock_webhook_event(
        'customer.subscription.trial_will_end',
        customer: mock_customer.id
      )
    }
    subject do
      StripeWebhookService::TrialWillEnd.new.call(event_trial_will_end)
    end

    it 'mails user with trial_will_end message' do
      trial_will_end_dbl = double(ActionMailer::MessageDelivery)
      allow(UserMailer).to receive(:trial_will_end).with(
        user_subscribed
      ).and_return(trial_will_end_dbl)
      expect(trial_will_end_dbl).to receive(:deliver_later).once
      subject
    end
  end

  describe StripeWebhookService::Dun do
    let(:event_invoice_payment_failed) {
      StripeMock.mock_webhook_event(
        'invoice.payment_failed',
        customer: mock_customer.id,
        attempt_count: 1,
        next_payment_attempt: Time.at(1.hour.from_now)
      )
    }
    subject do
      StripeWebhookService::Dun.new.call event_invoice_payment_failed
    end

    it 'mails the user with invoice_failed message' do
      attempt_count = event_invoice_payment_failed.data.object.attempt_count
      next_attempt_at = event_invoice_payment_failed.data.object.next_payment_attempt.to_i
      invoice_failed_dbl = double(ActionMailer::MessageDelivery)
      allow(UserMailer).to receive(:invoice_failed).with(
        user_subscribed,
        attempt_count,
        next_attempt_at
      ).and_return(invoice_failed_dbl)
      expect(invoice_failed_dbl).to receive(:deliver_later).once
      subject
    end
  end
end
