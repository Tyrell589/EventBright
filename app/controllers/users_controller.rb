class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource only: [:show, :edit, :update]

  # before_action :restrict_acess_to_owner, only: [:show]
  # before_action :set_user, only: [:edit, :update]

  def show
    @pagy, @administrated_events = pagy(@user.administrated_events.with_attached_images.order("created_at DESC"), items: 8)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Your infos have been edited successfully !"
      redirect_to @user
    else
      flash.now[:warning] = "Could not edit your infos"
      render :edit
    end
  end

private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :description)
  end

  # Cancancan take care of that

  # def restrict_acess_to_owner
  #   unless User.find(params[:id]) == current_user 
  #     flash[:warning] = "Sorry, but you are only allowed to view your own profile page." 
  #     redirect_to root_path
  #   end
  # end

  # def set_user 
  #   @user = User.find(params[:id])
  # end

end
