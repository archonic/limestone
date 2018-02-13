require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe 'welcome_email' do
    let(:mail) { UserMailer.welcome_email(user) }
    it 'renders the body' do
      expect(mail.body).to match "Welcome"
    end
  end

  describe 'billing_updated' do
    let(:mail) { UserMailer.billing_updated(user) }
    it 'renders the body' do
      expect(mail.body).to match "Your billing information has been updated"
    end
  end

  describe 'invoice_paid' do
    let(:mail) { UserMailer.invoice_paid(user, invoice) }
    let(:invoice) { create(:invoice) }
    it 'renders the body' do
      expect(mail.body.parts.length).to eq 2
      expect(mail.body.parts.first.body.raw_source).to match "We received your payment"
      expect(mail.body.parts.last.content_type).to eq "application/pdf"
    end
  end

  describe 'invoice_failed' do
    let(:mail) { UserMailer.invoice_failed(user, 1, 1.hour.from_now.to_s) }
    it 'renders the body' do
      expect(mail.body).to match "Invoice payment failed"
    end
  end

  describe 'trial_will_end' do
    let(:mail) { UserMailer.trial_will_end(user) }
    it 'renders the body' do
      expect(mail.body).to match "Your trial is almost over"
    end
  end
end
