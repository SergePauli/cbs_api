module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = cookies[:refresh_token]
      if token
        begin
          user_data = JsonWebToken.validate_token(token, expected_type: "refresh")
          if verified_user = User.find_by(id: user_data["data"]["id"])
            verified_user
          else
            reject_unauthorized_connection
          end
        rescue JWT::DecodeError
          raise ApiError.new("Валидация токена обновлений не успешна", :unauthorized)
        end
      elsif verified_user = User.find_by(id: cookies[:user_id])
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
