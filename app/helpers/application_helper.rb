# frozen_string_literal: true

module ApplicationHelper
  include IconHelper
  include CurrencyHelper

  # Appends to body tag if content_for :no_turbolink present
  def turbolinks?
    if content_for(:no_turbolink)
      { data: { no_turbolink: true } }
    else
      { data: nil }
    end
  end

  # For Devise custom sign in form
  # helper_method :resource_name, :resource, :devise_mapping
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
