class AvatarsController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.avatar.attach(params[:avatar]) if params[:avatar].present?
    redirect_back(fallback_location: root_path)
  end

  def destroy
    current_user.avatar.purge
    redirect_back(fallback_location: root_path)
  end
end
