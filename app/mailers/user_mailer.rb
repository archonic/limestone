class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(
      email_with_name(user),
      subject: '[Limestone] Welcome to Limestone!'
    )
  end

  def invoice_paid(user, invoice)
    @user = user
    @invoice = invoice
    mail(
      email_with_name(user),
      subject: '[Limestone] Payment receipt'
    )
  end

  def invoice_failed(user, invoice)
    @user = user
    @invoice = invoice
    mail(
      email_with_name(user),
      subject: '[Limestone] Payment failed'
    )
  end

  private

  def email_with_name(user)
    %("#{user.name}" <#{user.email}>)
  end
end
