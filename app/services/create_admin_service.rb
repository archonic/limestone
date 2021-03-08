# frozen_string_literal: true

class CreateAdminService
  # NOTE This user will be on a trial upon creation
  # enter a test card when prompted: https://stripe.com/docs/testing#cards
  def self.call
    admin = User.find_or_create_by!(email: ENV["ADMIN_EMAIL"]) do |u|
      u.password = ENV["ADMIN_PASSWORD"]
      u.password_confirmation = ENV["ADMIN_PASSWORD"]
      u.first_name = ENV["ADMIN_FIRST_NAME"]
      u.last_name = ENV["ADMIN_LAST_NAME"]
      u.trial_ends_at = Time.current + TRIAL_PERIOD_DAYS.days
      u.admin = true
      u.plan_id = Plan.first.id
    end
    SubscriptionService.new(admin, Plan.last.id).create_subscription!
  end
end
