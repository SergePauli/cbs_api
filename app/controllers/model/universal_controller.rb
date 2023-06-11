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
    @res = @res.ransack!(params[:q]).result unless params[:q].blank?
    if params[:count].blank?
      @res = @res.includes(params[:includes]) unless params[:includes].blank?
      if params[:data_set].blank?
        render json: @res.all
      else
        render json: @res.all.map { |el| el.custom_data(params[:data_set].to_sym) }
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

  # POST /model/add/:model_name
  # принимает параметры:
  # :<model_name> аттрибуты экзэмпляра модели для добаваления
  # :data_set задает типовой набор данных на выходе (:item, :card и т.д.)
  def create
    @res = @model_class.new permitted_params
    if @res.save
      check_audit_creation(@res)
      check_attributes(@res, params[params[:model_name]])
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
    old_map = create_string_values_map if (@res.respond_to? :audits)
    if @res.update(permitted_params)
      if (@res.respond_to? :audits)
        @res.reload
        new_map = create_string_values_map
        check_audit_updating(new_map, old_map)
        check_attributes(@res, params[params[:model_name]])
      end
      if params[:data_set].blank?
        render json: @res
      else
        render json: @res.custom_data(params[:data_set].to_sym), status: :ok
      end
    else
      render json: { errors: @res.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /model/:mode || []l_name/:id
  # принимает параметры:
  # :id
  # возвращает экземпляр модели <model_name> удаленный по его ID или ошибку
  def destroy
    # @audit = Audit.new(guid: @res.guid, action: :removed, table: params[:model_name], severity: :success, detail: @res.to_s, user_id: @current_user[:data][:id]) if @model_class.trackable?
    begin
      if @res && @res.destroy
        #@audit.save if @audit
        render json: @res
      else
        render json: { errors: @res.errors.full_messages }, status: :unprocessable_entity
      end
    rescue
      raise ApiError.new("Удаление записи в #{params[:model_name]} с id #{params[:id]} нарушает ограничение целостности", :unprocessable_entity)
    end
  end

  private

  def permitted_params
    begin
      params.require(params[:model_name].to_sym).permit(@model_class.permitted_params)
    rescue
      raise ApiError.new("Данные модели #{params[:model_name]} не верно указаны в запросе", :bad_request)
    end
  end

  def get_model_name
    params[:model_name] || controller_name.classify
  end

  def prepare_model
    model_name = get_model_name
    raise ApiError.new("Класс модели не указан в запросе", :bad_request) if model_name.blank?
    begin
      @model_class = model_name.constantize
    rescue
      raise ApiError.new("Класс модели #{model_name} не найден", :bad_request)
    end
    raise ApiError.new("Класс модели не принадлежит ActiveRecord", :bad_request) unless @model_class < ActiveRecord::Base
  end

  def find_record
    raise ApiError.new("Параметр id отсутствует  ", :bad_request) if params[:id].blank?
    begin
      @res = @model_class.find params[:id]
    rescue ActiveRecord::RecordNotFound
      raise ApiError.new("Запись не найдена для ID=#{params[:id]}", :not_found)
    end
  end

  # проверка на аудит добавления
  # регистрируем вновь созданные записи, требующие аудит
  def check_audit_creation(obj)
    if (obj.respond_to? :audits) && obj.audits.empty?
      audit = Audit.new({ action: :added, auditable: obj, user_id: @current_user[:data][:id] })
      audit.save
      obj.audits.push(audit)
    end
  end

  # проверка на аудит удаления
  # регистрируем удаление объектов, требующих аудит
  def audit_removed(obj)
    if (obj.respond_to? :audits)
      audit = Audit.new({ action: :removed, auditable: obj, user_id: @current_user[:data][:id] })
      audit.save
      obj.audits.push(audit)
    end
  end

  # проверка на аудит обновления
  # регистрируем изменение записи, с признаком аудита
  def check_audit_updating(new_map, old_map)
    new_map.each do |k, v|
      before = old_map[k]
      if v != before
        audit = Audit.new({ action: :updated, auditable_field: k, before: before, after: v, auditable: @res, user_id: @current_user[:data][:id] })
        audit.save
        @res.audits.push(audit)
      end
    end
  end

  # генерируем строковую карту значений
  def create_string_values_map
    result = {}
    params[params[:model_name]].each do |k, v|
      break if Auditable::no_audit_for.include?(k)
      if k.include? "_id"
        field = k.gsub("_id", "")
        child = @res.method(field).call
        result[field] = child.blank? ? "" : child.head
      elsif (k.include?("_attributes") && (v.class.name === "Array"))
        field = k.gsub("_attributes", "")
        child = @res.method(field).call
        all_string = child.reduce("") { |all_string, el| all_string + "{" + el.head + "} " }
        result[field] = all_string[0..-1]
      elsif k.include?("_attributes")
        field = k.gsub("_attributes", "")
        child = @res.method(field).call
        result[field] = child.blank? ? "" : child.head
      elsif (k != "id")
        child = @res.method(k).call
        if (child.class.name === "Date")
          result[k] = child.strftime("%d.%m.%Y")
        elsif (child.class.name === "DateTime")
          result[k] = child.strftime("%d.%m.%Y %H:%M")
        elsif (child.class.name === "TrueClass" || child.class.name === "FalseClass")
          result[k] = I18n.t child.to_s
        else
          result[k] = child.to_s
        end
      end
    end
    result
  end

  # рекурсивно получаем элементы списка или дочерние атрибуты,
  # и тоже проверяем на поддержку аудита
  def check_attributes(obj, params)
    params.each do |k, v|
      if k.include?("_attributes") && !Auditable::no_audit_for.include?(k)
        child = obj.method(k.gsub("_attributes", "")).call
        if v.class.name === "ActionController::Parameters"
          check_audit_creation(child)
          check_attributes(child, v)
        elsif v.class.name === "Array"
          v.each do |el|
            element = child.select { |objct| objct.list_key === el[:list_key] }
            check_audit_creation(element[0])
            check_attributes(element[0], el)
          end
        end
      end
    end
  end
end
