class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Allow additional user attributes
  def configure_permitted_parameters
    extra = [:username, :avatar]
    devise_parameter_sanitizer.permit(:sign_up, keys: extra)
    devise_parameter_sanitizer.permit(:account_update, keys: extra)
  end
end
