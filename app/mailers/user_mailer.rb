# frozen_string_literal: true

class UserMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def welcome_email(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: "[Limestone] Welcome!"
    )
  end

  def billing_updated(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: "[Limestone] Billing Updated"
    )
  end

  def source_expiring(user, source)
    @user = user
    @source = source
    mail(
      to: email_with_name(user),
      subject: "[Limestone] Your card is about to expire"
    )
  end

  def trial_will_end(user)
    @user = user
    mail(
      to: email_with_name(user),
      subject: "[Limestone] Your trial is ending soon!"
    )
  end

  private
    def email_with_name(user)
      %("#{user.name}" <#{user.email}>)
    end
end
