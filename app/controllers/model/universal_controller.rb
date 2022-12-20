# Универсальный CRUD контроллер
class Model::UniversalController < PrivateController
  before_action :prepare_model, only: [:index, :show, :create, :update, :destroy]
  before_action :find_record, only: [:show, :update, :destroy]

  # POST /model/:model_name
  # доступны параметры:
  #  :select для выбора нужных атрибутов модели,
  #  :data_set задает типовой набор данных (:item, :card и т.д.)
  #  :limit, :offset, :count пагинация
  #  :q - опции поиска и фильтрации от runsack
  #  :includes - оптимизация загрузки (problem of N+1 query)
  def index
    @res = @model_class
    @res = @res.limit(params[:limit].to_i) if params[:limit]
    @res = @res.offset(params[:offset].to_i) if params[:offset]
    @res = @res.select(params[:select]) unless params[:select].blank?
    @res = @res.ransack(params[:q]).result unless params[:q].blank?
    if params[:count].blank?
      @res = @res.includes(params[:includes]) unless params[:includes].blank?
      if !params[:render_options].blank?
        render json: @res.custom_data(params[:data_set].to_sym)
      else
        render json: @res.all
      end
    else
      render json: @res.count
    end
  end

  # GET /model/:model_name?id=:id&select=:select&data_set=:data_set
  # принимает параметры:
  # :id
  # :select  для выбора нужных атрибутов модели,
  # :data_set задает типовой набор данных на выходе (:item, :card и т.д.)
  # возвращает экземпляр модели <model_name> по его ID или ошибку
  def show
    @res = @model_class.select(params[:select]) unless params[:select].blank?
    if params[:data_set].blank?
      render json: @res
    else
      render json: @res.custom_data(params[:data_set].to_sym), status: :ok
    end
  end

  # POST /model/:model_name/add
  # принимает параметры:
  # :<model_name> аттрибуты экзэмпляра модели для добаваления
  # :data_set задает типовой набор данных на выходе (:item, :card и т.д.)
  def create
    @res = @model_class.new permitted_params
    if @res.save
      # if @model_class.trackable?
      #   @res_a = Audit.new(guid: @res.guid, action: :added, table: params[:model_name],
      #                      severity: :success, user_id: @current_user[:data][:id], detail: @res.to_s)
      #   @res_a.save!
      # end
      if params[:data_set].blank?
        render json: @res
      else
        render json: @res.custom_data(params[:data_set].to_sym), status: :ok
      end
    else
      render json: { errors: @res.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /model/:model_name/:id
  # принимает параметры:
  # :id
  # :<model_name> аттрибуты экзэмпляра модели для обновления
  # :data_set задает типовой набор данных на выходе (:item, :card и т.д.)
  # возвращает экземпляр модели <model_name> или ошибку
  def update
    #audits = []
    # if @model_class.trackable? && !params[:audits].blank?
    #   params[:audits].each do |audit|
    #     audits.push(Audit.new(guid: @res.guid, action: :updated, table: params[:model_name], field: audit[:field], after: audit[:after], before: audit[:before], severity: :success, summary: @res.to_s, detail: audit[:detail], user_id: @current_user[:data][:id]))
    #   end
    # end
    if @res.update(permitted_params)
      @res.touch
      #Audit.import audits if !audits.blank?
      find_record
      if params[:data_set].blank?
        render json: @res
      else
        render json: @res.custom_data(params[:data_set].to_sym), status: :ok
      end
    else
      render json: { errors: @res.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /model/:model_name/:id
  # принимает параметры:
  # :id
  # :select  для выбора нужных атрибутов модели,
  # :data_set задает типовой набор данных на выходе (:item, :card и т.д.)
  # возвращает экземпляр модели <model_name> удаленный по его ID или ошибку
  def destroy
    # @audit = Audit.new(guid: @res.guid, action: :removed, table: params[:model_name], severity: :success, detail: @res.to_s, user_id: @current_user[:data][:id]) if @model_class.trackable?
    if @res && @res.destroy
      #@audit.save if @audit
      render json: @res
    else
      render json: { errors: @res.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(params[:model_name].to_sym).permit(@model_class.permitted_params)
  end

  def get_model_name
    params[:model_name] || controller_name.classify
  end

  def prepare_model
    model_name = get_model_name
    raise ApiError.new("Model class not present", :bad_request) if model_name.nil? || model_name.strip == ""
    @model_class = model_name.constantize
    raise ApiError.new("Model class is not ActiveRecord", :bad_request) unless @model_class < ActiveRecord::Base
  end

  def find_record
    @res = @model_class.find params[:id]
  end
end
