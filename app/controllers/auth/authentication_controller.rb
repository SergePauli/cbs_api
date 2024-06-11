class Auth::AuthenticationController < PrivateController
  include ActionController::Cookies

  skip_before_action :authenticate_request, except: [:logout, :commer_token]

  # POST "auth/login"
  # авторизует пользователя :name проверяя пароль в  :password
  # генерирует токены обновлений и доступа
  # возвращает информацию о пользователе и токены
  def login
    begin
      @user = User.find_by!(name: params[:name])
    rescue ActiveRecord::RecordNotFound
      raise ApiError.new("Неверный пароль или имя пользователя", :unauthorized)
    end
    if @user&.authenticate(params[:password]) && @user.activated
      @dto = { id: @user.id, email: @user.email, role: @user.role, logged: @user.last_login }
      @user.last_login = DateTime.now
      raise ApiError.new("Ошибка регистрации входа", :internal_server_error) unless @user.save
      set_tokens
      render json: { user: @user.login_info, tokens: @tokens }, status: :ok
    else
      raise ApiError.new("Неверный пароль или имя пользователя", :unauthorized)
    end
  end

  # GET "auth/logout"
  # выполняет деавторизацию пользователя
  def logout
    token = cookies[:refresh_token]
    if !token.blank?
      REDIS.hdel "tokens", token
      cookies.delete :refresh_token
    end
    render json: { errors: "нет ошибок" }, status: :ok
  end

  # GET "auth/refresh" обновляем токен доступа
  # если токен обновлений в порядке - генерируется новый набор токенов
  # если указан параметр :with_user_info, то к информации добавляем инфу о пользователе
  def refresh
    token = cookies[:refresh_token]
    raise ApiError.new("Отсутствует токен обновлений", :unauthorized) if token.blank?
    begin
      user_data = JsonWebToken.validate_token token
    rescue JWT::DecodeError
      raise ApiError.new("Валидация токена обновлений не успешна", :unauthorized)
    end
    if REDIS.hget("tokens", token) == user_data["data"]["id"].to_s
      @dto = user_data["data"]
      set_tokens
      unless params["with_user_info"].blank?
        @user = User.find(user_data["data"]["id"])
        render json: { user: @user.login_info, tokens: @tokens }, status: :ok
      else
        render json: { tokens: @tokens }, status: :ok
      end
    else
      raise ApiError.new("Токен обновлений не действителен", :unauthorized)
    end
    REDIS.hdel("tokens", token)
  end

  #get "auth/commer" создаем  токен коммер-клиента
  def commer_token
    token = cookies[:refresh_token]
    begin
      user_data = JsonWebToken.validate_token token
    rescue JWT::DecodeError
      raise ApiError.new("Валидация токена обновлений не успешна", :unauthorized)
    end
    key = "commer_" + user_data["data"]["id"].to_s
    commer_token = REDIS.hget key, "token"
    @user = User.find(user_data["data"]["id"])
    if commer_token == nil
      commer_token = SecureRandom.uuid
      REDIS.hset key, "token", commer_token
      REDIS.hset commer_token, "user_id", user_data["data"]["id"].to_s
      # обновляем время жизни данных в кэше без использования
      REDIS.expire(key, PrivateController::ONE_DAY * 14)
      REDIS.expire(commer_token, PrivateController::ONE_DAY * 14)
    end
    cookies[:user_id] = { value: user_data["data"]["id"], expires: 12.hours, httponly: true }
    render json: { profile: @user.profile.edit, token: commer_token }, status: :ok
  end

  #post "auth/commer" авторизуем коммер-клиента по токену
  def commer_login
    begin
      user_id = REDIS.hget(params[:token], "user_id")
    rescue
      raise ApiError.new("Неверный токен доступа " + params[:token], :unauthorized)
    end
    @user = User.find(user_id.to_i)
    render json: @user.item, status: :ok
  end

  private

  def set_tokens
    @tokens = JsonWebToken.new_tokens(@dto)
    REDIS.hset "tokens", @tokens[:refresh], @dto[:id]
    cookies[:refresh_token] = { value: @tokens[:refresh], expires: JsonWebToken::LIFETIME.hour, httponly: true }
  end
end
