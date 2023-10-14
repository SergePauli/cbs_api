#главный класс приложения
class Contract < ApplicationRecord
  before_validation :generate_order, on: [:create, :update]

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
    stages.reduce(0) { |cost, stage| cost + stage.cost }
  end

  # реализация для набора данных basement
  def basement
    { id: id, contragent: contragent.item, task_kind: task_kind.item, cost: cost ? "%.2f" % cost : cost, governmental: governmental, signed_at: to_date_str(signed_at), external_number: external_number, revision: revision.basement, status: status.item }
  end

  # реализация для набора данных card
  def card
    super.merge(basement).merge({ code: code, order: order, year: year, stages: stages.map { |el| el.edit }, comments: stages.reduce([]) { |comments, el| comments + el.comments ? el.comments.map { |com| com.card } : [] } || [], audits: audits.map { |el| el.item } || [], revisions: revisions.map { |el| el.basement } })
  end

  # получаем массив разрешенных параметров запросов на добавление и изменение
  def self.permitted_params
    super | [:year, :code, :order, :contragent_id, :task_kind_id, :status_id, :governmental, :external_number, :signed_at] | [stages_attributes: Stage.permitted_params] | [comments_attributes: Comment.permitted_params] | [revisions_attributes: Revision.permitted_params]
  end

  private

  # назначаем сквозной номер контракту
  def generate_order
    return unless order.blank?
    last_one = Contract.where(year: year, code: code).last
    self.order = last_one.order + 1
  end
end
