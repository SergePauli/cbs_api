class Auth::AuthenticationController < PrivateController
  include ActionController::Cookies

  skip_before_action :authenticate_request, except: [:logout, :login_info]

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
      REDIS.hdel("tokens", token)
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
  end

  private

  def set_tokens
    @tokens = JsonWebToken.new_tokens(@dto)
    REDIS.hset "tokens", @tokens[:refresh], @dto[:id]
    cookies[:refresh_token] = { value: @tokens[:refresh], expires: JsonWebToken::LIFETIME.hour, httponly: true }
  end
end
