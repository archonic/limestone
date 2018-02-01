class UserMailer < ApplicationMailer
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
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Payment Receipt'
    )
  end

  def invoice_failed(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: '[Limestone] Payment Failed'
    )
  end

  private

  def email_with_name(user)
    %("#{user.full_name}" <#{user.email}>)
  end
end
