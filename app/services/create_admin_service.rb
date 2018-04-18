# frozen_string_literal: true

class CreateAdminService
  def self.call
    User.find_or_create_by!(
      email: ENV['ADMIN_EMAIL']
    ) do |u|
      u.password = ENV['ADMIN_PASSWORD']
      u.password_confirmation = ENV['ADMIN_PASSWORD']
      u.first_name = ENV['ADMIN_FIRST_NAME']
      u.last_name = ENV['ADMIN_LAST_NAME']
      u.trialing = false
      # admins obs don't need a plan, but it's better to have the validation in place
      u.plan_id = Plan.first.id
      u.admin!
    end
  end
end
