# Универсальный CRUD контроллер
class Model::UniversalController < PrivateController
  before_action :prepare_model, only: [:index, :show, :create, :update, :destroy]
  before_action :find_record, only: [:show, :update, :destroy]
  skip_before_action :authenticate_request, if: :this_is_export? #temporary !!!! used one time

  Model::UniversalController::const_set(:SIGNED, 1) #signed status id
  Model::UniversalController::const_set(:CLOSED, 5) #closed status id

  # !!!! used one time, for import data from old data base
  def this_is_export?
    !params[:export].blank?
  end

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
          render json: @res.all.map { |el| get_data_set(el) }           
      end
    else
      render json: @res.count || 0
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
      render json: get_data_set(@res), status: :ok
    end
  end

  # POST /model/add/:model_name
  # принимает параметры:
  # :<model_name> аттрибуты экземпляра модели для добаваления
  # :data_set задает типовой набор данных на выходе (:item, :card и т.д.)
  def create
    @res = @model_class.new permitted_params
    begin
      if @res.save
        if (!params[:comments].blank?)
          params[:comments].each do |comment|
            comment[:commentable] = @res            
            comment[:user_id] = this_is_export? ? 1 : @current_user[:data][:id]
            Comment.create comment
          end  
          add_updates("commented")
        end
        check_audit_creation(@res)
        check_attributes(@res, params[params[:model_name]])
        add_updates("added") if !this_is_export? && (@res.respond_to? :audits)        
        if params[:data_set].blank?
          render json: @res
        else
          render json: get_data_set(@res, false), status: :ok
        end
      else
        render json: { errors: @res.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      puts(@res.errors.full_messages)
      render json: { errors: ["Новая запись нарушает требования уникальности"] }, status: :unprocessable_entity
    end
  end

  # PUT /model/:model_name/:id
  # принимает параметры:
  # :id
  # :<model_name> аттрибуты экзэмпляра модели для обновления
  # :data_set задает типовой набор данных на выходе (:item, :card и т.д.)
  # возвращает экземпляр модели <model_name> или ошибку
  def update
    clean_keys(@res)
    old_map = create_string_values_map if (@res.respond_to? :audits)
    if @res.update(permitted_params)
      if (@res.respond_to? :audits)
        @res.reload          
        new_map = create_string_values_map
        add_updates("updated") if check_audit_updating(new_map, old_map) && !this_is_export?
        clean_keys(@res.contract) if params[:model_name] === "Revision"
        add_updates("commented") unless params[params[:model_name]][:comments_attributes].blank?
        add_updates("closed") if params[params[:model_name]][:status_id] == Model::UniversalController::CLOSED  && !this_is_export?
        add_updates("signed") if params[params[:model_name]][:status_id] == Model::UniversalController::SIGNED || params[params[:model_name]][:is_signed]
        check_attributes(@res, params[params[:model_name]])
      end
      if params[:data_set].blank?
        render json: @res, status: :ok
      else
        render json: get_data_set(@res, true), status: :ok
      end
    else
      render json: { errors: @res.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /model/:model_name/:id
  # принимает параметры:
  # :id
  # возвращает Item-набор удаленного объекта или ошибку
  def destroy
    audit = @res.head if @res.respond_to? :audits
    result = @res.item
    # удаляем все ключи объекта в кэше Redis
    clean_keys(@res)
    begin
      if @res && @res.destroy
        audit_removed(@res) if audit
        render json: result, status: :ok
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
    rescue Exception => e
      raise ApiError.new("Данные модели #{params[:model_name]} не верно указаны в запросе #{e.to_json}", :bad_request)
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

  # Очистка неактуальных ключей в кэше
  def clean_keys(obj)
    # получаем маску для всех ключей модели, в случае режима обновлений
    mask = "#{obj.class.name}_#{obj.id}*"
    # удаляем все устаревшие ключи, в случае обновления объекта в базе
    keys = REDIS.keys mask
    REDIS.del keys if keys
    # удаляем ключи и для объекта-владельца, если такой есть
    clean_keys(obj.main_model) if obj.respond_to? :main_model
  end

  # получаем набор данных для объекта
  # obj - экзэмпляр класса модели
  # на выходе hashmap его представления для :data_set
  def get_data_set(obj, update_mode = false)
    # получаем нужный ключ из Класса модели, ID записи и названия набора
    redis_key = "#{params[:model_name]}_#{obj.id}_#{params[:data_set]}"
    if update_mode 
      # удаляем все устаревшие ключи, в случае обновления объекта в базе
      clean_keys(obj)
    else
      # проверяем если готовое значение в REDIS
      json_str = REDIS.hget redis_key, "value"
    end
    if !json_str || json_str.blank?
      # если нет - получаем из СУБД данные и генерим карту объекта
      result = obj.custom_data(params[:data_set].to_sym)
      # и кэшируем в REDIS как JSON
      REDIS.hset redis_key, "value", result.to_json if !this_is_export?
    else
      # если да - Парсим JSON и получаем нужную карту объекта
      result = JSON.parse(json_str)
    end
    # обновляем время жизни данных в кэше без использования
    REDIS.expire(redis_key, Rails.configuration.redis_key_expire.to_i) if !this_is_export?
    result
  end

  # проверка на аудит добавления
  # регистрируем вновь созданные записи, требующие аудит
  def check_audit_creation(obj)
    if (obj.respond_to? :audits) && obj.audits.empty?
      audit = Audit.new({ action: (this_is_export? ? :imported : :added), auditable: obj, user_id: this_is_export? ? 1 : @current_user[:data][:id], detail: obj.head })
      audit.save
      obj.audits.push(audit)
    end
  end

  # аудит удаления
  # регистрируем удаление объектов, требующих аудит
  def audit_removed(obj)
    if (obj.respond_to? :audits)
      audit = Audit.new({ action: :removed, auditable: obj, user_id: @current_user[:data][:id], detail: obj.head })
      audit.save
      obj.audits.push(audit)
      obj.class.reflect_on_all_associations.all? do |assoc|
        audit_removed(obj.send(assoc.name)) if ((assoc.options[:dependent] == :destroy) && (obj.send(assoc.name).respond_to? :audits))
      end
    end
  end

  # проверка на аудит обновления
  # регистрируем изменение записи, с признаком аудита
  def check_audit_updating(new_map, old_map)
    updated = false
    new_map.each do |k, v|
      before = old_map[k]
      if v != before
        audit = Audit.new({ action: this_is_export? ? :imported : :updated, auditable_field: k, before: before, after: v, auditable: @res, detail: @res.head, user_id: this_is_export? ? 1 : @current_user[:data][:id] })
        audit.save
        @res.audits.push(audit)
        updated = true
      end
    end
    return updated
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
      elsif (k.include?("s_attributes"))
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
        elsif (["w_days", "c_days", "calendar_plan", "c_plan", "working_days", "working_prepayment", "calendar_prepayment", "calendar_days"].include?(child) || child.class.name === "TrueClass" || child.class.name === "FalseClass")
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
        begin
          child = obj.method(k.gsub("_attributes", "")).call
        rescue
          puts k, obj.to_json
        end
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
      elsif k === "_destroy" && !Auditable::no_audit_for.include?(k)
        audit_removed(obj)
      end
    end
  end

  # сохраняем в REDIS уведомления о изменениях
  def add_updates(name)
    users = REDIS.hvals "tokens"
    users.each do |user_id|
      m_name = params[:model_name] === "Revision" && name!="signed" ? "Contract" : params[:model_name]
      upd_key = user_id + ":#{name}:" + m_name
      json_str = REDIS.hget "updates", upd_key
      r_id = params[:model_name] === "Revision" && name!="signed" ? @res.contract.id : @res.id
      if !json_str.blank?
        # если да - Парсим JSON и добавляем id объекта
        updated = JSON.parse(json_str)
        updated.push(r_id) if !updated.include?(r_id)
        # и кэшируем в REDIS как JSON
        REDIS.hset "updates", upd_key, updated.to_json
      else
        # если нет - генерим новую карту обновлений
        # и кэшируем в REDIS как JSON
        REDIS.hset "updates", upd_key, [r_id].to_json
      end
    end
  end
end
