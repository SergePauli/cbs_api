# Получаем настройки соединения с Redis
redis_host = ENV["REDIS_ADDR"]&.split(":")&.first || "localhost"
redis_port = ENV["REDIS_ADDR"]&.split(":")&.last || 6379

# Создаем константу представляющую постоянное соединение с Redis
REDIS = Redis.new(host: redis_host, port: redis_port.to_i)
