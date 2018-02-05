# config/initializers/stripe.rb
Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_API_KEY']
}

Stripe.api_key = ENV['STRIPE_API_KEY']
Stripe.api_version = '2017-08-15'
StripeEvent.signing_secret = ENV['STRIPE_SIGNING_SECRET']

StripeEvent.configure do |events|
  # All webhooks are responded to with an empty 200 success, even if not subscribed to.
  # When you have a webhook url configured in stripe, a success response is required
  # to attempt payment shortly (1 hour) after invoice.created

  events.subscribe 'invoice.payment_succeeded', StripeWebhookService::RecordInvoicePaid.new
  events.subscribe 'customer.updated', StripeWebhookService::UpdateCustomer.new
  events.subscribe 'customer.subscription.trial_will_end', StripeWebhookService::TrialWillEnd.new
  events.subscribe 'invoice.payment_failed', StripeWebhookService::Dun.new
end
