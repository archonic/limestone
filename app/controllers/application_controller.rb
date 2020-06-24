# frozen_string_literal: true

require "application_helper"

class ApplicationController < ActionController::Base
  include Pundit
  include ActionView::Helpers::DateHelper
  protect_from_forgery with: :exception
  impersonates :user
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_access, if: :access_required?

  def after_sign_in_path_for(resource)
    if resource.on_trial?
      time_left = distance_of_time_in_words(Time.current, current_user.try(:trial_ends_at))
      flash[:notice] = "You have #{time_left} left in your trial!"
    end
    dashboard_path
  end

  protected
    def configure_permitted_parameters
      added_params = %i(first_name last_name avatar product_id)
      devise_parameter_sanitizer.permit :sign_up, keys: added_params
      devise_parameter_sanitizer.permit :account_update, keys: added_params
    end

    # Users are always allowed to manage their session, registration and subscription
    def access_required?
      user_signed_in? &&
        !current_user.on_trial_or_subscribed_to_any? &&
        !devise_controller? &&
        controller_name != "subscriptions"
    end

    # Redirect users in bad standing to billing page
    def check_access
      redirect_to billing_path,
        flash: {
          error: "Your trial has ended or your subscription has been cancelled. Please update your card - access will be restored once payment succeeds."
        }
    end
end
