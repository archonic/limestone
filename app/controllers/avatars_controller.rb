class AvatarsController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  respond_to :json
  layout false

  def update
    avatar = params[:user][:avatar]

    respond_to do |format|
      if @user.save && avatar
        @user.avatar.attach(avatar)
        format.html { redirect_to edit_user_registration_path, notice: 'Avatar updated' }
      end
    end
  end

  def destroy
    @user.avatar.purge_later

    respond_to do |format|
      if @user.save
        format.html { redirect_to edit_user_registration_path, notice: 'Avatar deleted' }
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def avatar_params
    params.require(:user).permit(:avatar)
  end
end
