# config/initializers/stripe.rb
Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_API_KEY']
}

Stripe.api_key = ENV['STRIPE_API_KEY']
Stripe.api_version = '2017-08-15'
StripeEvent.signing_secret = ENV['STRIPE_SIGNING_SECRET']

class TrialWillEnd
  def call(event)
    # Bug user to enter a payment source if they don't have any
    # Invite them to contact support if things aren't going well
    return true
  end
end

class RecordInvoicePaid
  def call(event)
    event_data = event.data.object
    user = User.find_by(stripe_id: event_data.customer)
    if user.nil?
      StripeLogger.error "INVOICE PAID ERROR: No user found with stripe_id #{event_data.customer}."
      return true
    end

    # Ignore invoices for $0.00 such as trial period invoice
    return true if event_data.total.zero?

    invoice = user.invoices.where(stripe_id: event_data.id).first_or_initialize
    lines = event_data.lines.data
    invoice.assign_attributes(
      amount: event_data.total,
      currency: event_data.currency,
      number: event_data.number,
      paid_at: Time.at(event_data.date).to_datetime,
      lines: lines
    )

    invoice.save!
    UserMailer.invoice_paid(user, invoice).deliver_later
    return true
  end
end

class UpdateCustomer
  def call(event)
    event_data = event.data.object
    user = User.find_by(stripe_id: event_data.id)
    if user.nil?
      StripeLogger.error "UpdateCustomer ERROR: No user found with stripe_id #{event_data.customer}"
      return true
    end

    # Update card info
    # Each customer should have just one source. Log if that's not the case.
    sources = event_data.sources
    if sources.total_count > 1
      StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.customer} has #{sources.total_count} sources. There's supposed to have one!"
    elsif sources.total_count == 1
      source = sources.first
      user.assign_attributes(
        card_last4: source.last4,
        card_type: source.brand,
        card_exp_month: source.exp_month,
        card_exp_year: source.exp_year
      )
    else
    end

    # Update subscription status and current_period_end
    # Each customer should have just one subscription. Log if that's not the case.
    subscriptions = event_data.subscriptions
    if subscriptions.total_count > 1
      StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.customer} has #{subscriptions.total_count} subscriptions. They're supposed to have one!"
    elsif subscriptions.total_count == 1
      subscription = subscriptions.first
      # Update customer valid until
      # TODO Update user ROLE based on subscription status
      user.assign_attributes(
        current_period_end: Time.at(subscription.current_period_end).to_datetime
      )
    else
    end

    user.save!
    UserMailer.billing_updated(user).deliver_later if sources.total_count == 1
    return true
  end
end

class Dun
  def call(event)
    event_data = event.data.object
    puts "======= Payment failed! Harrass them! #{event_data}"
    user = User.find_by(stripe_id: event_data.customer)
    if user.nil?
      StripeLogger.error "PAYMENT FAILURE ERROR: No user found with stripe_id #{event_data.customer}"
      return true
    end

    UserMailer.invoice_failed(user).deliver_later
    return true
  end
end

StripeEvent.configure do |events|
  # invoice.created is automatically responsed to with an empty 200 success
  #   When you have specified an endpoint in Stripe, this response is
  #   required to attempt payment shortly (1 hour) after invoice.created

  events.subscribe 'customer.subscription.trial_will_end', TrialWillEnd.new
  events.subscribe 'invoice.payment_succeeded', RecordInvoicePaid.new
  events.subscribe 'customer.updated', UpdateCustomer.new
  events.subscribe 'invoice.payment_failed', Dun.new
end
