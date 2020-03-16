# frozen_string_literal: true

class AvatarsController < ApplicationController
  before_action :set_user, only: %i(update destroy)
  before_action :set_avatar, only: %i(update destroy)
  respond_to :json
  layout false

  def update
    if params.try(:[], :user).try(:[], :avatar).present?
      avatar_uploaded = params[:user][:avatar]
    else
      head :unauthorized && return
    end

    if @user.save && avatar_uploaded
      @avatar.attach(avatar_uploaded)
      redirect_to edit_user_registration_path, notice: "Avatar updated"
    end
  end

  def destroy
    @avatar.purge

    if @user.save
      redirect_to edit_user_registration_path, notice: "Avatar deleted"
    end
  end

  private
    def set_user
      @user = current_user
      raise Pundit::NotAuthorizedError if @user.nil?
    end

    def set_avatar
      @avatar = @user.avatar || @user.avatar.new
    end

    def avatar_params
      params.require(:user).permit(:avatar)
    end
end
