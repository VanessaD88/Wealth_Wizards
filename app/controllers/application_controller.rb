class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Handle 404 errors (not found)
  # Note: Routing errors are handled by catch-all route in config/routes.rb
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  # Handle 500 errors (internal server error)
  rescue_from StandardError, with: :render_internal_server_error unless Rails.env.development?

  protected

  # Allow additional user attributes
  def configure_permitted_parameters
    extra = [:username, :avatar]
    devise_parameter_sanitizer.permit(:sign_up, keys: extra)
    devise_parameter_sanitizer.permit(:account_update, keys: extra)
  end

  private

  # Render 404 error page
  def render_not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found }
      format.json { render json: { error: 'Not found' }, status: :not_found }
      format.any { head :not_found }
    end
  end

  # Render 500 error page
  def render_internal_server_error(exception)
    # Log the error for debugging
    Rails.logger.error "Internal Server Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html { render 'errors/internal_server_error', status: :internal_server_error }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
      format.any { head :internal_server_error }
    end
  end
end
