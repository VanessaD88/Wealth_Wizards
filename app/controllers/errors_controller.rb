class ErrorsController < ApplicationController
  # Skip authentication for error pages - users need to see errors even if not logged in
  skip_before_action :authenticate_user!

  # 404 Not Found error page
  def not_found
    render status: :not_found
  end

  # 500 Internal Server Error page: exception to StandardError
  def internal_server_error
    render status: :internal_server_error
  end
end
