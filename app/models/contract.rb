#главный класс приложения
class Contract < ApplicationRecord
  before_validation :generate_order, on: [:create, :update]
  before_validation :fix_task_kind, on: [:create, :update]

  # аудит изменений
  include Auditable

  # Комментирование
  include Commentable

  # используются режим сроков, статусы, основная задача
  include Executable

  # Весь документо-оборот по контракту
  has_many :revisions, -> { order("priority ASC") }, autosave: true, dependent: :destroy, inverse_of: :contract
  accepts_nested_attributes_for :revisions, allow_destroy: true

  has_one :revision, -> { where(used: true, priority: 0) }

  # Этапы (как минимум один)
  has_many :stages, -> { order("priority ASC") }, autosave: true, dependent: :destroy, inverse_of: :contract
  accepts_nested_attributes_for :stages, allow_destroy: true
  has_one :stage, -> { where(used: true) }

  # Контрагент
  belongs_to :contragent
  validates_associated :contragent

  # Статус
  belongs_to :status
  validates_associated :status

  validates :order, uniqueness: { scope: [:year, :code, :order] }

  # номер
  def name
    "#{code}/#{year.to_s[-2..-1]}/#{order.to_s.rjust(3, "0")}"
  end

  # стоимость
  def cost
    stages.reduce(0) { |cost, stage| cost + (stage.cost || 0)}
  end

  # реализация для набора данных basement
  def basement
    begin
      { id: id, contragent: contragent.item, task_kind: task_kind.item, cost: cost ? "%.2f" % cost : cost, governmental: governmental, signed_at: to_date_str(signed_at), deadline_at: to_date_str(deadline_at), closed_at: to_date_str(closed_at), external_number: external_number, revision: revision.nil? ? revisions[0].basement : revision.basement, status: status.item, region: contragent.real_addr.nil? ? nil : contragent.real_addr.address.area.item}
    rescue 
      puts "Не найдена ревизия к #{name} или другая ошибка"
      return {id: id, contragent: contragent.item, task_kind: task_kind.item, cost: cost ? "%.2f" % cost : cost, governmental: governmental, signed_at: to_date_str(signed_at), deadline_at: to_date_str(deadline_at), closed_at: to_date_str(closed_at), external_number: external_number, status: status.item, region: contragent.real_addr.nil? ? nil : contragent.real_addr.address.area.item, revision: "Не найдена ревизия" }
    end   
  end

  # реализация для набора данных card
  def card
    super.merge(basement).merge({ code: code, order: order, year: year, use_stage: stage ? stage.id : stages[0].id, stages: stages.map { |el| el.edit }, comments: stages.reduce([]) { |comments, el| comments + el.comments ? el.comments.map { |com| com.card } : [] } || [], revisions: revisions.map { |el| el.basement }, expire_at: stages[0].priority > 0 ? to_date_str(deadline_at) : to_date_str(stages[0].deadline_at) })
  end

  # получаем массив разрешенных параметров запросов на добавление и изменение
  def self.permitted_params
    super | [:year, :code, :order, :contragent_id, :task_kind_id, :status_id, :governmental, :external_number, :signed_at, :deadline_at, :closed_at] | [stages_attributes: Stage.permitted_params] | [comments_attributes: Comment.permitted_params] | [revisions_attributes: Revision.permitted_params]
  end

  ransacker :total_costs do
    query = "(SELECT SUM(stages.cost) FROM stages WHERE stages.contract_id = contracts.id  GROUP BY stages.contract_id)"
    Arel.sql(query)
  end

  ransacker :is_funded do
    query = "(SELECT CASE 
              WHEN st.funded_stages = 0 THEN NULL 
              WHEN st.funded_stages = st.all_stages THEN true 
              ELSE false 
            END FROM (SELECT count(*) as all_stages, sum(cast(is_funded as INT)) as funded_stages FROM stages WHERE stages.contract_id = contracts.id) as st)"
    Arel.sql(query)
  end
  ransacker :funded_at do
    query = "(SELECT MAX(stages.funded_at) FROM stages WHERE stages.contract_id = contracts.id)"
    Arel.sql(query)
  end

  ransacker :contract_number do
    query = "(SELECT contracts.code || '/'  || RIGHT(cast(contracts.year as varchar(4)),2) || '/' || RIGHT('000' || cast(contracts.order as varchar(3)),3))"
    Arel.sql(query)
  end

  private

  # назначаем сквозной номер контракту
  def generate_order
    return unless order.blank?
    last_one = Contract.where(year: year, code: code).order(:order).last
    self.order = (last_one ? last_one.order || 0 : 0) + 1    
  end

  def fix_task_kind
    return if code.nil? || !task_kind_id.nil? || !task_kind.nil?
    self.task_kind = TaskKind.find_by(code: code)
    if task_kind
      self.stages[0].task_kind_id = task_kind.id
    else
      raise ActiveRecord::RecordNotFound, "Не найден тип задачи #{code}"
    end    
  end  
end
