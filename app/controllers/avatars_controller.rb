class AvatarsController < ApplicationController
  before_action :set_user, only: [:update, :destroy]
  before_action :set_avatar, only: [:update, :destroy]
  respond_to :json
  layout false

  def update
    if params.try(:[], :user).try(:[], :avatar).present?
      avatar_uploaded = params[:user][:avatar]
    else
      head :unauthorized and return
    end

    respond_to do |format|
      if @user.save && avatar_uploaded
        @avatar.attach(avatar_uploaded)
        format.html { redirect_to edit_user_registration_path, notice: 'Avatar updated' }
      end
    end
  end

  def destroy
    @avatar.purge

    respond_to do |format|
      if @user.save
        format.html { redirect_to edit_user_registration_path, notice: 'Avatar deleted' }
      end
    end
  end

  private

  def set_user
    @user = current_user
    raise Pundit::NotAuthorizedError unless @user.present?
  end

  def set_avatar
    @avatar = @user.avatar || @user.avatar.new
  end

  def avatar_params
    params.require(:user).permit(:avatar)
  end
end
