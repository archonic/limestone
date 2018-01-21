class Users::RegistrationsController < Devise::RegistrationsController
  # POST /resource
  # NOTE This needs the whole action from Devise to insert subscription creation at the right time.
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      create_stripe_subscription(resource)
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      bypass_sign_in resource, scope: resource_name
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def destroy
    @@subscription_service = SubscriptionService.new(current_user, params)
    if @@subscription_service.destroy_subscription
      resource.discard
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message! :notice, :destroyed
      yield resource if block_given?
      redirect_to cancelled_path
    else
      set_flash_message! :error, :stripe_communication
      respond_with resource
    end
  end

  protected

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def after_sign_up_path_for(resource)
    if resource.subscribed?
      dashboard_path
    else
      billing_path
    end
  end

  private

  # TODO Check if this can be done in before_create callback in user model
  def create_stripe_subscription(resource)
    customer = Stripe::Customer.create(email: resource.email)

    begin
      # Change this to a selected plan if you have more than 1
      plan = Stripe::Plan.list(limit: 1).first
      subscription = customer.subscriptions.create(
        source: params[:stripeToken],
        plan: plan.id,
        trial_end: Rails.env.try(:trial_period) || 14.days.from_now.to_i
      )
      subscription_data = {
        stripe_id: customer.id,
        stripe_subscription_id: subscription.id,
      }
      resource.update(subscription_data)
    rescue => e
      puts "Log this error! #{e.inspect}"
    end
  end
end
