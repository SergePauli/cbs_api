# Этап контракта
class Stage < MutableData

  # аудит изменений
  include Auditable

  # фильтр на используемые
  include Usable

  # используются режим сроков, статусы, основная задача
  include Executable

  # Комментирование
  include Commentable

  # задачи
  has_many :tasks, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :tasks, allow_destroy: true

  # исполнители
  has_many :stage_performers, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :stage_performers, allow_destroy: true

  # заказы
  has_many :stage_orders, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :stage_orders, allow_destroy: true

  # платежи
  has_many :payments, -> { order("payment_at ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :payments, allow_destroy: true

  belongs_to :contract

  belongs_to :status, optional: true

  validates_associated :contract
  validates_associated :task_kind
  validate :validate_status

  validates :contract, uniqueness: { scope: [:contract, :priority] }
  alias_attribute :state, :task_kind # для поддержки MutableData
  accepts_nested_attributes_for :task_kind

  # наименование этапа заменяется наименованием контракта в одно-этапных договорах
  # в много-этапных выводим номер контракта, номер этапа и задачу
  def name
    priority === 0 ? "#{contract.name} #{task_kind.name}" : "#{contract.name}_Э#{priority} #{task_kind.name}"
  end

  def head
    used ? name : "*" + name
  end

  # кастомное присвоение статуса, с учетом несуществующего ID
  def status_id=(val)
    begin
      Status.find(val) unless val.nil?
    rescue
      nil
    end
    super
  end

  # реализация для набора данных basement
  def basement
    { id: id, task_kind: task_kind.item, status: status ? status.item : nil, cost: cost ? "%.2f" % cost : cost, deadline_kind: deadline_kind || contract.deadline_kind, duration: "#{duration}#{I18n.t(deadline_kind || contract.deadline_kind)}", deadline_at: deadline_at, completed_at: completed_at, funded_at: funded_at, invoice_at: invoice_at, sended_at: sended_at, is_sended: is_sended, ride_out_at: ride_out_at, is_ride_out: is_ride_out, tasks: used_items(tasks) || nil, stage_orders: used_items(stage_orders) || nil, performers: used_items(stage_performers) || nil, payments: payments.map { |item| item.item } || nil }
  end

  # реализация для набора данных card
  def card
    super.merge({ contract: contract.basement, comments: comments.map { |el| el.item } || [], audits: audits.map { |el| el.item } || [] }).merge(basement)
  end

  # получаем массив разрешенных параметров запросов на добавление и изменение
  def self.permitted_params
    super | [:contract_id, :task_kind_id, :status_id, :cost, :completed_at, :deadline_at, :duration, :deadline_kind, :invoice_at, :sended_at, :ride_out_at, :is_sended, :is_ride_out, :funded_at] | [tasks_attributes: Task.permitted_params] | [stage_orders_attributes: StageOrder.permitted_params] | [payments_attributes: Payment.permitted_params] | [comments_attributes: Comment.permitted_params]
  end

  private

  # кастомная валидация  статуса (в случае если статус указан, но неверно, мы узнаем об этом)
  def validate_status
    errors.add(:status, ["(status invalid) Указано невалидное значение id статуса"]) if status_id != nil && status.nil?
  end
end
