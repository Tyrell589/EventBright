class ApplicationController < ActionController::Base
  # For pagination
  include Pagy::Backend
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
      keys: [:email, :username]) # authentication key is set to "login" and not "email" anymore, so we have to manually permit email
    devise_parameter_sanitizer.permit(:account_update,
      keys: [:first_name, :last_name, :description, :email])
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to main_app.root_url, alert: exception.message, status: :not_found }
      end
  end
end
