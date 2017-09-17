class AvatarsController < ApplicationController
  before_action :set_avatar, only: [:show, :edit, :update, :destroy]
  respond_to :json
  layout false

  # GET /avatars
  # GET /avatars.json
  def index
    @avatars = Avatar.all
  end

  def show
    @avatar_props = {
      url: current_user.avatar_url(:xl)
    }
  end

  def new
    @avatar = Avatar.new
  end

  # POST /avatars
  # POST /avatars.json
  def create
    @avatar = Avatar.new(avatar_params)

    respond_to do |format|
      if @avatar.save
        # format.html { redirect_to @avatar, notice: 'Avatar was successfully created.' }
        # format.js { render status: :ok }
        format.json { render :show, status: :created, location: @avatar }
      else
        # format.html { render :new }
        format.json { render json: @avatar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /avatars/1
  # PATCH/PUT /avatars/1.json
  def update
    respond_to do |format|
      if @avatar.update(avatar_params)
        format.json { render :show, status: :ok, location: @avatar }
        # format.js { render status: :ok }
      else
        format.json { render json: @avatar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /avatars/1
  # DELETE /avatars/1.json
  def destroy
    @avatar.destroy
    respond_to do |format|
      format.html { redirect_to avatars_url, notice: 'Avatar was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_avatar
      @avatar = Avatar.find(params[:id])
    end

    def avatar_params
      params.require(:avatar).permit(:image, :user_id)
    end
end
