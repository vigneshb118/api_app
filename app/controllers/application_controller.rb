class ApplicationController < ActionController::API
  # Add CORS headers for better compatibility
  before_action :set_cors_headers

  private

  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "POST, GET, PUT, PATCH, DELETE, OPTIONS"
    headers["Access-Control-Allow-Headers"] = "Origin, Content-Type, Accept, Authorization, X-Requested-With"
    headers["Access-Control-Max-Age"] = "1728000"
  end
end
