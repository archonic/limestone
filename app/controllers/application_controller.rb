class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  impersonates :user
  before_action :configure_permitted_parameters, if: :devise_controller?

  def current_user_subscribed?
    user_signed_in? && current_user.subscribed?
  end
  helper_method :current_user_subscribed?

  def after_sign_in_path_for(resource)
    resource.discarded? ? subscribe_path : dashboard_path
  end

  protected

  def configure_permitted_parameters
    added_params = [:first_name, :last_name, :avatar]
    devise_parameter_sanitizer.permit :sign_up, keys: added_params
    devise_parameter_sanitizer.permit :account_update, keys: added_params
  end
end
