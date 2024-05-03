class ProfileController < PrivateController

  # GET profile/activity/:profile_id
  def activity
    if params[:profile_id]
      render json: [{ name: "created", count: 3, ids: [1, 6, 5] }]
    else
      render json: []
    end
  end

  # GET profile/contract/:contract_id
  # keep selected contractract id in session
  def contract
    key = "commer_" + @current_user[:data][:id].to_s
    begin
      REDIS.hset(key, "contract_id", params[:contract_id]) if params[:contract_id]
      ActionCable.server.broadcast(key, { id: params[:contract_id] })
      render json: { message: "Выбор контракта ID=" + params[:contract_id] + " сохранен в кэше" }
    rescue Redis::BaseError => e
      render json: { message: ["Выбор контракта ID=" + params[:contract_id] + " не сохранен в кэше; " + "#{e.message}"] }
    end
  end

  private

  # def get_user
  #   @user = User.find(@current_user[:data][:id])
  # end

end
