class PrivateController < ApplicationController
  PrivateController::const_set(:ONE_DAY, 3600 * 12) # 12 hours
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    if !params[:token].blank?
      key = "commer_" + params[:user_id].to_s
      if REDIS.hget(key, "token") != params[:token]
        raise ApiError.new("Валидация коммер-токена не успешна: #{params[:token]}", :unauthorized)
      end
      @current_user = { data: { id: params[:user_id] } }
    elsif params[:export] 
      @current_user = { data: { id: 1 } } # admin user import data
    else
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
end
