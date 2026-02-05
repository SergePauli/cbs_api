# Токены доступа
#
# access_token для Authorization heder
# refresh_token для сессии
#
class JsonWebToken
  # уникальное значение для генерации токенов
  SECRET = Rails.application.secrets.secret_key_base
  ALGORITHM = "HS256"
  # Срок действия токена обновлений в системе в часах
  LIFETIME = 144
  # Срок действия токена доступа в часах
  REFRESHTIME = 1

  class << self
    def new_tokens(payload)
      now = Time.current.to_i

      # генерация токена обновлений
      exp = LIFETIME.hours.from_now.to_i
      tokens = { refresh: generate_token(payload, exp, "refresh", now) }

      # генерация токена доступа
      exp = REFRESHTIME.hours.from_now.to_i
      tokens[:access] = generate_token(payload, exp, "access", now)
      tokens
    end

    def secr
      SECRET || "нет кода"
    end

    # валидируем токен
    def validate_token(token, expected_type: nil)
      body = JWT.decode(token, secret!, true, { algorithm: ALGORITHM, verify_not_before: true, verify_iat: true })[0]
      if expected_type.present? && body["token_type"] != expected_type
        raise JWT::DecodeError, "Недопустимый тип токена"
      end
      HashWithIndifferentAccess.new body
    end

    private

    def generate_token(payload, exp, token_type, now)
      exp_payload = { data: payload, exp: exp, nbf: now, iat: now, token_type: token_type }
      JWT.encode exp_payload, secret!, ALGORITHM
    end

    def secret!
      raise ArgumentError, "JWT secret_key_base is not configured" if SECRET.blank?

      SECRET
    end
  end
end
