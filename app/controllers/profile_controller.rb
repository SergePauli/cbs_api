class ProfileController < PrivateController
  skip_before_action :authenticate_request, except: [:activity, :contract]
  # GET profile/activity/:profile_id
  def activity
    if params[:profile_id]
      render json: [{ name: "created", count: 3, ids: [1, 6, 5] }]
    else
      render json: []
    end
  end

  # POST profile/contract/
  # open selected contractract in commer-client
  def open_contract
    key = "commer_" + params[:user_id].to_s
    if REDIS.hget(key, "token") != params[:token]
      render json: { message: "Валидация токена не успешна" }, status: :unauthorized
    else
      begin
        contract_id = REDIS.hget key, "contract_id"
        contract = Contract.find(contract_id) if contract_id.present?
        if contract.present?
          render json: { id: contract.id, number: contract.name, contragent: contract.contragent.name, revisions: contract.revisions.map { |el| el.basement } }
        else
          render json: { message: "Контракт не найден по ID=" + contract_id }, status: 422
        end
      rescue e
        render json: { message: e.message }, status: 422
      end
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
