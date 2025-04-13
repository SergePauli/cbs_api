class ProfileController < PrivateController
  include ActionController::Cookies
  skip_before_action :authenticate_request, except: [:activity, :contract]
  # GET profile/activity
  # get updates
  def activity
    result = []
    user_id = REDIS.hget "tokens", cookies[:refresh_token]
    updates = REDIS.hkeys "updates"
    updates = updates.select { |el| el.include? user_id }
    updates.each do |el|
      data = {}
      data_keys = el.split(":")
      data["action"] = data_keys[1]
      data["model"] = (data_keys[2] == 'Revision' && data_keys[1] == 'signed')  ? 'доп' : (I18n.t data_keys[2])
      data["ids"] = JSON.parse(REDIS.hget("updates", el))
      result.push(data)
      REDIS.hdel "updates", el
    end
    render json: result, status: 200
  end

  # GET profile/activity_clean
  # clean updates
  def activity_clean
    user_id = REDIS.hget "tokens", cookies[:refresh_token]
    updates = REDIS.hkeys "updates"
    updates = updates.select { |el| el.include? user_id }
    updates.each do |el|
      REDIS.hdel "updates", el
    end
    render json: { message: "обновления очищены" }, status: 200
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
