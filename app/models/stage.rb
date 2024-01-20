# Этап контракта
class Stage < MutableData

  # присвоение задачи контракта, если не задана специфическая
  after_initialize do |stage|
    stage.task_kind_id = stage.contract.task_kind_id if (stage.task_kind_id.nil? && !stage.contract.nil?)
  end

  # аудит изменений
  include Auditable

  # фильтр на используемые
  include Usable

  # используются режим сроков, статусы, основная задача
  include Executable

  # Комментирование
  include Commentable

  # Режимы оплаты
  enum payment_deadline_kind: [:c_plan, :c_days, :w_days]

  # задачи
  has_many :tasks, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :tasks, allow_destroy: true

  # исполнители
  has_many :performers, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :performers, allow_destroy: true

  # заказы
  has_many :stage_orders, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :stage_orders, allow_destroy: true

  belongs_to :contract, inverse_of: :stages

  belongs_to :status, optional: true

  validates_associated :contract

  validate :validate_status

  validates :contract, uniqueness: { scope: [:contract, :priority] }
  alias_attribute :state, :task_kind # для поддержки MutableData
  alias_attribute :main_model, :contract # для поддержки обновления модели-владельца в Redis
  accepts_nested_attributes_for :task_kind

  # наименование этапа заменяется наименованием контракта в одно-этапных договорах
  # в много-этапных выводим номер контракта, номер этапа и задачу
  def name
    priority === 0 ? "#{contract.name}" : "#{contract.name}_Э#{priority}"
  end

  def head
    used ? "#{name} #{task_kind.name}" : "* #{name} #{task_kind.name}"
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
    { id: id, name: name, priority: priority, task_kind: task_kind.item, status: status ? status.item : nil, cost: cost ? "%.2f" % cost : cost, deadline_kind: deadline_kind, duration: duration, start_at: to_date_str(start_at), deadline_at: to_date_str(deadline_at), closed_at: to_date_str(closed_at), payment_at: to_date_str(payment_at),
      payment_deadline_kind: payment_deadline_kind, payment_duration: payment_duration, payment_deadline_at: to_date_str(payment_deadline_at), funded_at: to_date_str(funded_at), invoice_at: to_date_str(invoice_at), sended_at: to_date_str(sended_at), is_sended: is_sended, ride_out_at: to_date_str(ride_out_at), is_ride_out: is_ride_out, completed_at: to_date_str(completed_at), registry_quarter: registry_quarter, registry_year: registry_year, tasks: tasks.map { |el| el.edit } || nil, stage_orders: used_items(stage_orders) || nil, performers: performers.map { |el| el.edit } || nil }
  end

  # реализация для набора данных card
  def card
    super.merge(basement).merge({ comments: comments.map { |el| el.card } || [], contract: contract.basement, used: used, list_key: list_key })
  end

  def edit
    basement.merge({ comments: comments.map { |el| el.card } || [], used: used, list_key: list_key })
  end

  # получаем массив разрешенных параметров запросов на добавление и изменение
  def self.permitted_params
    super | [:contract_id, :task_kind_id, :status_id, :cost, :start_at, :completed_at, :closed_at, :deadline_at, :duration, :deadline_kind, :payment_deadline_kind, :payment_duration, :payment_deadline_at, :payment_at, :invoice_at, :sended_at, :ride_out_at, :registry_quarter, :registry_year, :is_sended, :is_ride_out, :funded_at] | [tasks_attributes: Task.permitted_params] | [performers_attributes: Performer.permitted_params] | [stage_orders_attributes: StageOrder.permitted_params] | [comments_attributes: Comment.permitted_params]
  end

  ransacker :register do
    query = "(SELECT cast(stages.registry_quarter as varchar(2)) || '.'  || cast(stages.registry_year as varchar(4)))"
    Arel.sql(query)
  end

  ransacker :szi do
    query = "(SELECT (count(*) > 0)  from tasks where stages.id = tasks.stage_id and tasks.task_kind_id = 10)"
    Arel.sql(query)
  end

  private

  # кастомная валидация  статуса (в случае если статус указан, но неверно, мы узнаем об этом)
  def validate_status
    errors.add(:status, ["(status invalid) Указано невалидное значение id статуса"]) if status_id != nil && status.nil?
  end
end
