require "rails_helper"

RSpec.describe "Auth::Authentications", type: :request do
  fixtures :users
  let(:test_user) {
    REDIS.del "tokens"
    users(:admin)
  }
  describe "POST /auth/login" do
    it "При неверном пароле, экшин должен возвращать :unauthorized" do
      headers = { "ACCEPT" => "application/json" }
      post "/auth/login", params: { name: test_user.name, password: "invalid_password" }, headers: headers
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include("Неверный пароль или имя пользователя")
    end
    it "При неверном пoльзователе, экшин должен возвращать :unauthorized" do
      headers = { "ACCEPT" => "application/json" }
      post "/auth/login", params: { password: "42password" }, headers: headers
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include("Неверный пароль или имя пользователя")
    end
    it "При валидных параметрах, экшин должен возвращать :ok" do
      headers = { "ACCEPT" => "application/json" }
      post "/auth/login", params: { name: test_user.name, password: "42password" }, headers: headers
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include test_user.head
      expect(response.body).to include cookies[:refresh_token]
    end
  end

  describe "GET /auth/refresh" do
    let (:token) {
      REDIS.hkeys("tokens")[0]
    }
    it "должен обновлять информацию о токенах и возвращать :ok" do
      cookies[:refresh_token] = token
      travel_to ((JsonWebToken::REFRESHTIME + 2).hours.from_now) do
        get "/auth/refresh"
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include token
        expect(REDIS.hget("tokens", token)).to be_nil
      end
    end
    it "должен возвращать :unauthorized для неавторизованого запроса" do
      get "/auth/refresh"
      expect(response).to have_http_status(:unauthorized)
    end
    it "должен возвращать :unauthorized для просроченного токена обновлений" do
      cookies[:refresh_token] = token
      travel_to ((JsonWebToken::LIFETIME + 20).hours.from_now) do
        get "/auth/refresh"
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include "Валидация токена обновлений не успешна"
      end
    end
  end
  describe "GET /auth/logout" do
    let (:token) {
      REDIS.hkeys("tokens")[0]
    }
    it "должен очищать информацию о токенах и возвращать :ok" do
      cookies[:refresh_token] = token
      get "/auth/logout"
      expect(response).to have_http_status(:ok)
      expect(cookies[:refresh_token]).to eq ""
      expect(REDIS.hget("tokens", token)).to be_nil
    end
    it "должен возвращать :unauthorized для неавторизованого запроса" do
      get "/auth/logout"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
