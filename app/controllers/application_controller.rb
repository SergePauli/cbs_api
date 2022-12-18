class ApplicationController < ActionController::API

  ## API Universal Exception Handling
  class ApiError < StandardError
    def initialize(message, status)
      super(message)
      @status = status
    end

    attr_reader :status
  end

  rescue_from ApiError, :with => :api_error

  def api_error(exception)
    render json: { errors: [exception.message] }, status: exception.status
  end
end
