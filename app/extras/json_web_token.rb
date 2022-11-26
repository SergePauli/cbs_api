# Токены доступа
#
# access_token для Authorization heder
# refresh_token для сессии
#
class JsonWebToken
  # уникальное значение для генерации токенов
  SECRET = Rails.application.secrets.secret_key_base.freeze
  # Максимальное время сессии пользователя,
  # после авторизации в системе
  LIFETIME = 144
  # Время обновления токена доступа
  REFRESHTIME = 1

  class << self
    # генерация токена обновлений
    def refresh_token(payload)
      exp = LIFETIME.hours.from_now.to_i
      generate_token(payload, exp)
    end

    # генерация токена доступа
    def access_token(payload)
      exp = REFRESHTIME.hours.from_now.to_i
      generate_token(payload, exp)
    end

    # валидируем токен
    def validate_token(token)
      body = JWT.decode(token, SECRET, true, { algorithm: "HS256" })[0]
      HashWithIndifferentAccess.new body
    end

    # удаляем токен обновлений из Redis
    def remove_token(user_id)
      REDIS.del("token:#{user_id}")
    end

    # обновляем или сохраняем токен обновлений в Redis
    def save_token(user_id)
      exp = LIFETIME.hours.from_now.to_i
      token = generate_token(user_id, exp)
      REDIS.set("token:#{user_id}", token, ex: exp)
      token
    end

    private

    def generate_token(payload, exp)
      exp_payload = { data: payload, exp: exp }
      JWT.encode exp_payload, SECRET, "HS256"
    end
  end
end
