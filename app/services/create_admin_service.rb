class CreateAdminService
  def call
    User.find_or_create_by!(
      email: Rails.application.secrets.admin_email
    ) do |u|
      u.password = Rails.application.secrets.admin_password
      u.password_confirmation = Rails.application.secrets.admin_password
      u.first_name = Rails.application.secrets.admin_first_name
      u.last_name = Rails.application.secrets.admin_last_name
      u.admin!
    end
  end
end
