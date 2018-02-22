# Manages all incoming stripe webhooks
class StripeWebhookService
  def no_user_error(klass, user_stripe_id)
    StripeLogger.error "#{klass.class.name.upcase} ERROR: No user found with stripe_id #{user_stripe_id}."
    yield
  end

  def assign_role(user_attributes, stripe_plan)
    plan = Plan.find_by( stripe_id: stripe_plan.id )
    if plan.present?
      user_attributes[:role] = plan.associated_role
    else
      StripeLogger.error "AssignRole ERROR: No local plan found for #{stripe_plan.id}"
    end
  end

  def process_subscription_status(subscription, user_attributes)
    case subscription.status
    when 'trialing'
      user_attributes[:trialing] = true
      user_attributes[:past_due] = false
      assign_role(user_attributes, subscription.plan)
    when 'active'
      user_attributes[:trialing] = false
      user_attributes[:past_due] = false
      assign_role(user_attributes, subscription.plan)
    when 'past_due'
      user_attributes[:past_due] = true
      assign_role(user_attributes, subscription.plan)
    when 'cancelled', 'unpaid'
      user_attributes[:role] = 'removed'
    else
      StripeLogger.error "#{self.class.name} ERROR: Unknown subscription status #{subscription.status}."
    end
  end

  class RecordInvoicePaid < StripeWebhookService
    def call(event)
      event_data = event.data.object
      user = User.find_by(stripe_id: event_data.customer)
      no_user_error(self, event_data.customer) { return } if user.nil?

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
      invoice.save
      UserMailer.invoice_paid(user, invoice).deliver_later
      return true
    end
  end

  class UpdateCustomer < StripeWebhookService
    def call(event)
      event_data = event.data.object
      user = User.find_by(stripe_id: event_data.id)
      no_user_error(self, event_data.id) { return } if user.nil?
      # Hold all attributes until assignment. Makes it easier to test.
      user_attributes = {}

      # Update card info
      # Each customer should have just one source. Log if that's not the case.
      sources = event_data.sources
      if sources.present?
        if sources.total_count > 1
          StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has #{sources.total_count} sources. There's supposed to have one!"
        elsif sources.total_count == 1
          source = sources.first
          user_attributes[:card_last4] = source.last4
          user_attributes[:card_type] = source.brand
          user_attributes[:card_exp_month] = source.exp_month
          user_attributes[:card_exp_year] = source.exp_year
        end
      else
        StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has no source."
      end

      # Update role based on subscription status and current_period_end
      # Each customer should have just one subscription. Log if that's not the case.
      subscriptions = event_data.subscriptions
      if subscriptions.present?
        if subscriptions.total_count > 1
          StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has #{subscriptions.total_count} subscriptions. They're supposed to have one!"
        elsif subscriptions.total_count == 1
          subscription = subscriptions.first
          process_subscription_status(subscription, user_attributes)
          user_attributes[:current_period_end] = Time.at(subscription.current_period_end).to_datetime
        end
      else
        StripeLogger.error "UpdateCustomer ERROR: Customer #{event_data.id} has no subscription."
      end
      user.update user_attributes
      # This event is fired on new trials. Only send email if the source is present.
      UserMailer.billing_updated(user).deliver_later if sources.try(:total_count) == 1
      return true
    end
  end

  # Fires when switching plans
  class UpdateSubscription < StripeWebhookService
    def call(event)
      subscription = event.data.object
      user = User.find_by(stripe_id: subscription.customer)
      no_user_error(self, subscription.customer) { return } if user.nil?
      user_attributes = {}
      process_subscription_status(subscription, user_attributes)
      user_attributes[:current_period_end] = Time.at(subscription.current_period_end).to_datetime
      user.update(user_attributes)
    end
  end

  class TrialWillEnd < StripeWebhookService
    def call(event)
      event_data = event.data.object
      user = User.find_by(stripe_id: event_data.customer)
      no_user_error(self, event_data.customer) { return } if user.nil?
      UserMailer.trial_will_end(user).deliver_later
      return true
    end
  end

  class SourceExpiring < StripeWebhookService
    def call(event)
      card = event.data.object
      user = User.find_by(stripe_id: card.customer)
      no_user_error(self, card.customer) { return } if user.nil?
      UserMailer.source_expiring(user, card).deliver_later
      return true
    end
  end

  class Dun < StripeWebhookService
    def call(event)
      event_data = event.data.object
      user = User.find_by(stripe_id: event_data.customer)
      no_user_error(self, event_data.customer) { return } if user.nil?
      UserMailer.invoice_failed(
        user,
        event_data.attempt_count,
        event_data.next_payment_attempt.to_i
      ).deliver_later
      return true
    end
  end
end
