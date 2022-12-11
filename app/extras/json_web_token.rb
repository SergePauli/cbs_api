# Токены доступа
#
# access_token для Authorization heder
# refresh_token для сессии
#
class JsonWebToken
  # уникальное значение для генерации токенов
  SECRET = Rails.application.secrets.secret_key_base.freeze
  # Срок действия токена обновлений в системе в часах
  LIFETIME = 144
  # Срок действия токена доступа в часах
  REFRESHTIME = 1

  class << self
    def new_tokens(payload)
      # генерация токена обновлений
      exp = LIFETIME.hours.from_now.to_i
      tokens = { refresh: generate_token(payload, exp) }

      # генерация токена доступа
      exp = REFRESHTIME.hours.from_now.to_i
      generate_token(payload, exp)
      tokens[:access] = generate_token(payload, exp)
      tokens
    end

    # валидируем токен
    def validate_token(token)
      body = JWT.decode(token, SECRET, true, { algorithm: "HS256" })[0]
      HashWithIndifferentAccess.new body
    end

    private

    def generate_token(payload, exp)
      exp_payload = { data: payload, exp: exp }
      JWT.encode exp_payload, SECRET, "HS256"
    end
  end
end
