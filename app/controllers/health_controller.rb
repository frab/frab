class HealthController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_authenticity_token

  def show
    # Check database connection
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      database_status = "ok"
    rescue => e
      database_status = "error: #{e.message}"
    end

    # Check if Rails is properly initialized
    rails_status = Rails.application.initialized? ? "ok" : "not initialized"

    status = {
      status: "ok",
      timestamp: Time.current.iso8601,
      database: database_status,
      rails: rails_status
    }

    # Return error status if any component is unhealthy
    if database_status != "ok" || rails_status != "ok"
      status[:status] = "error"
      render json: status, status: :service_unavailable
    else
      render json: status, status: :ok
    end
  end
end