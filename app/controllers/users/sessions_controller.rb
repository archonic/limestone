class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    # If user has cancelled their account, send them to subscribe again
    if resource.discarded?
      respond_with resource, location: subscribe_path
    else
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end
