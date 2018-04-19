# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe 'welcome_email' do
    let(:mail) { UserMailer.welcome_email(user) }
    it 'renders' do
      expect(mail.body).to match 'Welcome'
    end
  end

  describe 'billing_updated' do
    let(:mail) { UserMailer.billing_updated(user) }
    it 'renders' do
      expect(mail.body).to match 'Your billing information has been updated'
    end
  end

  describe 'invoice_paid' do
    let(:mail) { UserMailer.invoice_paid(user, invoice) }
    let(:invoice) { create(:invoice) }
    it 'renders' do
      expect(mail.body.parts.length).to eq 2
      expect(mail.body.parts.first.body.raw_source).to match 'We received your payment'
      expect(mail.body.parts.last.content_type).to eq 'application/pdf'
    end
  end

  describe 'invoice_failed' do
    let(:mail) { UserMailer.invoice_failed(user, 1, 1.hour.from_now.to_s) }
    it 'renders' do
      expect(mail.body).to match 'Invoice payment failed'
    end
  end

  describe 'source_expiring' do
    # Assignment of attributes has to be done like this, sadly
    let(:source) do
      card = Stripe::Card.new
      card.brand = 'Visa'
      card.last4 = '1234'
      card.exp_month = '2'
      card.exp_year = '2018'
      card
    end
    let(:mail) { UserMailer.source_expiring(user, source) }
    it 'renders' do
      expect(mail.body).to match 'Your card is about to expire'
    end
  end

  describe 'trial_will_end' do
    let(:mail) { UserMailer.trial_will_end(user) }
    it 'renders' do
      expect(mail.body).to match 'Your trial is almost over'
    end
  end
end
