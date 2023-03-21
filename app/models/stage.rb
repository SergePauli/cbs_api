# Этап контракта
class Stage < MutableData
  # аудит изменений
  include Auditable

  # фильтр на используемые
  include Usable

  # задачи
  has_many :tasks, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :tasks, allow_destroy: true

  # исполнители
  has_many :performers, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :performers, allow_destroy: true

  # заказы
  has_many :stage_orders, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :stage_orders, allow_destroy: true

  # платежи
  has_many :payments, -> { order("payment_at ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :payments, allow_destroy: true

  belongs_to :contract
  belongs_to :task_kind
  belongs_to :status
  validates_associated :contract
  validates_associated :task_kind
  validates_associated :status
  validates :contract, uniqueness: { scope: [:contract, :priority] }
  alias_attribute :state, :task_kind # для поддержки MutableData
  accepts_nested_attributes_for :task_kind

  def name
    priority === 0 ? "#{contract.name}" : "#{contract.name}-#{priority}-#{task_kind.name}"
  end

  def card
    super.merge({ contract: contract.item, task_kind: task_kind.item, status: status.item, cost: "%.2f" % cost, deadline: deadline || contract.deadline, duration: duration, sended_at: sended_at, is_sended: is_sended, ride_out_at: ride_out_at, is_ride_out: is_ride_out, tasks: used_items(tasks), stage_orders: used_items(stage_orders), performers: used_items(performers) })
  end
end
