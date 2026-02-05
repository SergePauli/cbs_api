RSpec.describe JsonWebToken do
  it "должны быть определены настройки и сроки жизни токенов" do
    expect(ENV["AUTH_JWT_ISSUER"]).not_to be_blank
    expect(ENV["AUTH_JWT_AUDIENCE"]).not_to be_blank
    expect(ENV["AUTH_JWT_HMAC_SECRET"]).not_to be_blank
    expect(ENV["AUTH_JWT_CLOCK_SKEW_SEC"]).to match(/\A\d+\z/)
    expect(JsonWebToken::LIFETIME).to be_between(1, 10000)
    expect(JsonWebToken::REFRESHTIME).to be_between(1, 24)
  end

  describe "#new_tokens :refresh" do
    let(:tokens) {
      travel_to ((JsonWebToken::LIFETIME + 20).hours.ago) do
        JsonWebToken.new_tokens "test value"
      end
    }
    it "Должна быть создана строка токена содержащая нужный payload" do
      expect(tokens[:refresh]).to include("eyJhbGciOiJIUzI1NiJ9")
    end

    it "Должен успешно декодироваться" do
      body = JWT.decode(tokens[:refresh], JsonWebToken.secr, true, { verify_expiration: false, algorithm: "HS256" })[0]
      expect(body["data"]).to eq "test value"
      expect(body["token_type"]).to eq "refresh"
      expect(body["iat"]).to be_present
      expect(body["nbf"]).to be_present
      expect(body["iss"]).to eq ENV["AUTH_JWT_ISSUER"]
      expect(Array.wrap(body["aud"])).to include(*ENV["AUTH_JWT_AUDIENCE"].split(",").map(&:strip))
    end

    it "Не должен быть валиден по истечении срока действия" do
      expect {
        JWT.decode tokens[:refresh], JsonWebToken.secr, true, { algorithm: "HS256" }
      }.to raise_error(JWT::ExpiredSignature)
    end
  end

  describe "#new_tokens :access" do
    let(:tokens) {
      travel_to ((JsonWebToken::REFRESHTIME + 2).hours.ago) do
        JsonWebToken.new_tokens "test value"
      end
    }

    it "Должна быть создана строка токена содержащая нужный payload" do
      expect(tokens[:access]).to include("eyJhbGciOiJIUzI1NiJ9")
    end

    it "Должен успешно декодироваться" do
      body = JWT.decode(tokens[:access], JsonWebToken.secr, true, { verify_expiration: false, algorithm: "HS256" })[0]
      expect(body["data"]).to eq "test value"
      expect(body["token_type"]).to eq "access"
      expect(body["iat"]).to be_present
      expect(body["nbf"]).to be_present
      expect(body["iss"]).to eq ENV["AUTH_JWT_ISSUER"]
      expect(Array.wrap(body["aud"])).to include(*ENV["AUTH_JWT_AUDIENCE"].split(",").map(&:strip))
    end

    it "Не должен быть валиден по истечении срока действия" do
      expect {
        JWT.decode tokens[:access], JsonWebToken.secr, true, { algorithm: "HS256" }
      }.to raise_error(JWT::ExpiredSignature)
    end
  end

  describe "#validate_token" do
    let(:expired_token) {
      travel_to ((JsonWebToken::REFRESHTIME + 2).hours.ago) do
        JsonWebToken.new_tokens "test value"
      end
    }

    it "Должно генерироваться JWT::ExpiredSignature по истечении срока действия" do
      expect {
        JsonWebToken.validate_token expired_token[:access]
      }.to raise_error(JWT::ExpiredSignature)
    end

    let(:right_token) {
      JsonWebToken.new_tokens "test value"
    }

    let(:decoded_data) {
      JsonWebToken.validate_token right_token[:access]
    }

    it "Декодированые данные должны содержать исходный payload" do
      expect(decoded_data[:data]).to eq "test value"
    end

    it "должен валидировать access токен по типу" do
      expect {
        JsonWebToken.validate_token(right_token[:access], expected_type: "access")
      }.not_to raise_error
    end

    it "должен отклонять токен с неверным типом" do
      expect {
        JsonWebToken.validate_token(right_token[:access], expected_type: "refresh")
      }.to raise_error(JWT::DecodeError)
    end
  end
  # describe "#save_token" do
  #   let(:saved_token) {
  #     JsonWebToken.save_token(1000)
  #   }

  #   it "Метод должен возвращать сохраненный токен обновлений для указанного id пользователя" do
  #     res = JsonWebToken.validate_token(saved_token)
  #     expect(res[:data]).to eq 1000
  #   end

  #   let(:save_result) {
  #     JsonWebToken.validate_token(REDIS.get("token:1000"))
  #   }
  #   it "Должен считываться сохраненный в Redis токен обновлений" do
  #     expect(save_result[:data]).to eq 1000
  #   end
  # end

  # describe "#remove_token" do
  #   let(:del_result) {
  #     JsonWebToken.remove_token 1000
  #   }
  #   it "Должен возвращаться 1 в случае успешного удаления токена" do
  #     expect(del_result).to eq 1
  #   end
  #   let(:del_repeat_result) {
  #     JsonWebToken.remove_token 1001
  #   }
  #   it "Должен возвращаться 0 в случае если ключ токена не найден" do
  #     expect(del_repeat_result).to eq 0
  #   end
  #end
end
