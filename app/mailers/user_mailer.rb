class UserMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def welcome_email(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Welcome!'
    )
  end

  def billing_updated(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Billing Updated'
    )
  end

  def invoice_paid(user, invoice)
    @user = user
    @invoice = invoice
    attachments["limestone_invoice_#{@invoice.paid_at.strftime('%Y_%m_%d')}.pdf"] = {
      mime_type: 'application/pdf',
      content: invoice_path(@invoice, format: :pdf)
    }
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Payment Receipt'
    )
  end

  def invoice_failed(user, attempt_count, next_attempt_at)
    @user = user
    @attempt_count = attempt_count
    # ActiveJob serialization doesn't support DateTime,
    # so we send seconds since unix epoch and use that in the view.
    @next_attempt_at = next_attempt_at
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Payment Failed'
    )
  end

  def source_expiring(user, source)
    @user = user
    @source = source
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Your card is about to expire'
    )
  end

  def trial_will_end(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Your trial is ending soon!'
    )
  end

  private

  def email_with_name(user)
    %("#{user.name}" <#{user.email}>)
  end
end
