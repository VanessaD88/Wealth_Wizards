class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Global exception handler for 404 (Not Found) errors
  # Automatically catches ActiveRecord::RecordNotFound exceptions (e.g., when User.find(id)
  # doesn't find a record). Routing errors (invalid URLs) are handled separately by the
  # catch-all route in config/routes.rb (see line 60).
  # When triggered: Calls render_not_found method (see private section below)
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  # Global exception handler for 500 (Internal Server Error) errors
  # Automatically catches ALL StandardError exceptions (which includes most Ruby/Rails errors)
  # in production/staging environments only. In development, Rails shows detailed error pages
  # instead so developers can debug issues.
  # When triggered: Calls render_internal_server_error method (see private section below)
  # Environment: Only active in production/staging (disabled in development for debugging)
  rescue_from StandardError, with: :render_internal_server_error unless Rails.env.development?

  protected

  # Allow additional user attributes
  def configure_permitted_parameters
    extra = [:username, :avatar]
    devise_parameter_sanitizer.permit(:sign_up, keys: extra)
    devise_parameter_sanitizer.permit(:account_update, keys: extra)
  end

  private

  # Renders the 404 (Not Found) error page when a record or route doesn't exist
  # This method is called automatically by Rails when:
  #   - ActiveRecord::RecordNotFound is raised (e.g., User.find(999999))
  #   - A catch-all route matches an invalid path (see config/routes.rb)
  # Formats handled:
  #   - HTML: Renders app/views/errors/not_found.html.erb with full layout
  #   - JSON: Returns simple JSON error for API requests
  #   - Any other: Returns HTTP 404 status with no body
  # Status code: 404 Not Found (tells browsers/search engines the resource doesn't exist)
  def render_not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found }
      format.json { render json: { error: 'Not found' }, status: :not_found }
      format.any { head :not_found }
    end
  end

  # Renders the 500 (Internal Server Error) page when an unexpected exception occurs
  # This method is called automatically by Rails when:
  #   - Any StandardError exception is raised in any controller action
  #   - ONLY in production/staging environments (see line 10: unless Rails.env.development?)
  #   - In development, Rails shows detailed error pages instead for debugging
  # Common scenarios that trigger this:
  #   - Database connection failures
  #   - External API timeouts/errors (e.g., AI service in challenges_controller)
  #   - Code bugs (nil errors, division by zero, missing methods)
  #   - JSON parsing errors (e.g., invalid AI response format)
  # Error logging:
  #   - Logs exception message and full backtrace to Rails logger
  #   - Check logs/ directory or production logs for full error details
  # Formats handled:
  #   - HTML: Renders app/views/errors/internal_server_error.html.erb with full layout
  #   - JSON: Returns simple JSON error for API requests
  #   - Any other: Returns HTTP 500 status with no body
  # Status code: 500 Internal Server Error (tells browsers it's a server-side problem)
  # @param exception [StandardError] The exception object that triggered this handler
  def render_internal_server_error(exception)
    # Log the error for debugging - check production logs when investigating issues
    Rails.logger.error "Internal Server Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html { render 'errors/internal_server_error', status: :internal_server_error }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
      format.any { head :internal_server_error }
    end
  end
end
