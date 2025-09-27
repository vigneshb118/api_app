class Api::V1::HealthController < ApplicationController
  def index
    render json: { 
      status: 'ok', 
      message: 'API is running successfully',
      timestamp: Time.current,
      version: '1.0.0'
    }
  end
end