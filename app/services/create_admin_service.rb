# frozen_string_literal: true

class CreateAdminService
  # NOTE This user will not have active billing upon creation
  # enter a test card when prompted: https://stripe.com/docs/testing#cards
  def self.call
    User.find_or_create_by!( email: ENV["ADMIN_EMAIL"] ) do |u|
      u.password = ENV["ADMIN_PASSWORD"]
      u.password_confirmation = ENV["ADMIN_PASSWORD"]
      u.first_name = ENV["ADMIN_FIRST_NAME"]
      u.last_name = ENV["ADMIN_LAST_NAME"]
      u.admin = true
      u.product_id = Product.first.id
    end
  end
end
