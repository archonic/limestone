# frozen_string_literal: true

Pay.setup do |config|
  config.chargeable_class = "Pay::Charge"
  config.chargeable_table = "pay_charges"

  # For use in the receipt/refund/renewal mailers
  config.business_name = "Limestone"
  config.business_address = "1234 Whatever Street"
  config.application_name = "Limestone App"
  config.support_email = "support@example.com"

  # NOTE Stripe can send styled and branded emails on your behalf
  # https://dashboard.stripe.com/settings/billing/automatic
  # If you turn on emails for upcoming renewal, failed payments and invoicing,
  # make sure you're not doubling up emails for the same event here.
  # See Pay's emails here:
  # https://github.com/pay-rails/pay/blob/master/app/mailers/pay/user_mailer.rb
  config.send_emails = true

  config.automount_routes = true
  config.routes_path = "/pay" # Only when automount_routes is true
end
