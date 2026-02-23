# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  cors_allow_origin = ENV.fetch(
    "CORS_ALLOW_ORIGIN",
    "http://localhost:3000"
  )
  cors_origins = cors_allow_origin.split(",").map(&:strip).reject(&:empty?).map do |origin|
    if origin.start_with?("/") && origin.end_with?("/")
      Regexp.new(origin[1..-2])
    else
      origin
    end
  end

  allow do
    origins(*cors_origins)
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
