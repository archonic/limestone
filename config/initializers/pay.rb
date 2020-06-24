# frozen_string_literal: true

Pay.setup do |config|
  config.chargeable_class = 'Pay::Charge'
  config.chargeable_table = 'pay_charges'

  # For use in the receipt/refund/renewal mailers
  config.business_name = "Limestone"
  config.business_address = "1234 Whatever Street"
  config.application_name = "Limestone App"
  config.support_email = "support@example.com"

  config.send_emails = true

  config.automount_routes = true
  config.routes_path = "/pay" # Only when automount_routes is true
end
