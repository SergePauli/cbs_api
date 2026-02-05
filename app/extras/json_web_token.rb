# Токены доступа
#
# access_token для Authorization heder
# refresh_token для сессии
#
class JsonWebToken
  ALGORITHM = "HS256"
  ISSUER_ENV_KEY = "AUTH_JWT_ISSUER"
  AUDIENCE_ENV_KEY = "AUTH_JWT_AUDIENCE"
  SECRET_ENV_KEY = "AUTH_JWT_HMAC_SECRET"
  CLOCK_SKEW_ENV_KEY = "AUTH_JWT_CLOCK_SKEW_SEC"

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
      secret!
    end

    # валидируем токен
    def validate_token(token, expected_type: nil)
      decode_options = {
        algorithm: ALGORITHM,
        verify_not_before: true,
        verify_iat: true,
        verify_iss: true,
        iss: issuer!,
        verify_aud: true,
        aud: audience!,
        leeway: clock_skew_sec
      }
      body = JWT.decode(token, secret!, true, decode_options)[0]
      if expected_type.present? && body["token_type"] != expected_type
        raise JWT::DecodeError, "Недопустимый тип токена"
      end
      HashWithIndifferentAccess.new body
    end

    private

    def generate_token(payload, exp, token_type, now)
      exp_payload = {
        data: payload,
        exp: exp,
        nbf: now,
        iat: now,
        iss: issuer!,
        aud: audience!,
        token_type: token_type
      }
      JWT.encode exp_payload, secret!, ALGORITHM
    end

    def secret!
      secret = ENV[SECRET_ENV_KEY].to_s
      raise ArgumentError, "#{SECRET_ENV_KEY} is not configured" if secret.blank?

      secret
    end

    def issuer!
      issuer = ENV[ISSUER_ENV_KEY].to_s
      raise ArgumentError, "#{ISSUER_ENV_KEY} is not configured" if issuer.blank?

      issuer
    end

    def audience!
      audience = ENV[AUDIENCE_ENV_KEY].to_s.split(",").map(&:strip).reject(&:blank?)
      raise ArgumentError, "#{AUDIENCE_ENV_KEY} is not configured" if audience.blank?

      audience
    end

    def clock_skew_sec
      raw_value = ENV.fetch(CLOCK_SKEW_ENV_KEY, "0")
      value = Integer(raw_value, 10)
    rescue ArgumentError, TypeError
      raise ArgumentError, "#{CLOCK_SKEW_ENV_KEY} must be an integer >= 0"
    else
      raise ArgumentError, "#{CLOCK_SKEW_ENV_KEY} must be >= 0" if value.negative?

      value
    end
  end
end
