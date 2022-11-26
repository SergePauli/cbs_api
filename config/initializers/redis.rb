# Получаем настройки соединения с Redis
redis_host = Rails.application.secrets.redis && Rails.application.secrets.redis["host"] || "localhost"
redis_port = Rails.application.secrets.redis && Rails.application.secrets.redis["port"] || 6379

# Создаем константу представляющую постоянное соединение с Redis
REDIS = Redis.new(host: redis_host, port: redis_port.to_i)
