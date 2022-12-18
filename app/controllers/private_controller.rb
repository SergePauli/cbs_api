class PrivateController < ApplicationController
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers["Authorization"]
    raise ApiError.new("Отсутствует токен доступа", :bad_request) unless header
    header = header.split(" ").last
    begin
      @current_user = JsonWebToken.validate_token header
    rescue JWT::DecodeError
      raise ApiError.new("Валидация токена доступа не успешна", :unauthorized)
    end
  end
end
