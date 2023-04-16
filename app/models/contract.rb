#главный класс приложения
class Contract < ApplicationRecord
  before_validation :generate_order, if: -> { order.blank? }

  # аудит изменений
  include Auditable

  # Комментирование
  include Commentable

  # используются режим сроков, статусы, основная задача
  include Executable

  # Весь документо-оборот по контракту
  has_many :revisions, -> { order("priority ASC") }, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :revisions, allow_destroy: true

  has_one :revision, -> { where(used: true, priority: 0) }

  # Этапы (как минимум один)
  has_many :stages, -> { order("priority ASC") }, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :stages, allow_destroy: true

  # Контрагент
  belongs_to :contragent
  validates_associated :contragent

  # Статус
  belongs_to :status
  validates_associated :status

  validates :order, uniqueness: { scope: [:year, :code, :order] }

  # номер контракта
  def name
    "#{code}-#{year}-#{order.to_s.rjust(2, "0")}"
  end

  # кастомное присвоение задачи, с учетом несуществующего ID
  def task_kind_id=(val)
    begin
      tk = TaskKind.find(val) unless val.nil?
      if tk
        self.code = tk.code
        tk
      end
    rescue
      self.code = nil
      nil
    end
    super
  end

  # реализация для набора данных basement
  def basement
    { id: id, contragent: contragent.item, cost: cost ? "%.2f" % cost : cost, deadline_kind: deadline_kind, governmental: governmental, signed_at: signed_at, revision: revision.basement, status: status.item }
  end

  # реализация для набора данных card
  def card
    super.merge(basement).merge({ task_kind: task_kind.item, code: code, order: order, year: year, stages: stages.map { |el| el.basement }, comments: comments.map { |el| el.item } || [], audits: audits.map { |el| el.item } || [], revisions: revisions.map { |el| el.item } })
  end

  # получаем массив разрешенных параметров запросов на добавление и изменение
  def self.permitted_params
    super | [:contragent_id, :task_kind_id, :status_id, :cost, :governmental, :deadline_kind, :signed_at] | [stages_attributes: Stage.permitted_params] | [comments_attributes: Comment.permitted_params] | [revisions_attributes: Revision.permitted_params]
  end

  # назначаем сквозной номер контракту
  def generate_order
    last_one = Contract.where(year: year, code: code).last
    self.order = last_one.order + 1
  end
end
