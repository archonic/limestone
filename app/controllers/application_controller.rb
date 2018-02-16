class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  impersonates :user
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    resource.removed? ? subscribe_path : dashboard_path
  end

  protected

  def configure_permitted_parameters
    added_params = [:first_name, :last_name, :avatar, :plan_id]
    devise_parameter_sanitizer.permit :sign_up, keys: added_params
    devise_parameter_sanitizer.permit :account_update, keys: added_params
  end
end
