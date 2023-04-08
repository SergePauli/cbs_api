#главный класс приложения
class Contract < ApplicationRecord

  # аудит изменений
  include Auditable

  # Комментирование
  include Commentable

  # используются режим сроков, статусы, основная задача
  include Executable

  # Весь документо-оборот по контракту
  has_many :revisions, -> { order("priority ASC") }, inverse_of: :revision, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :revisions, allow_destroy: true

  # Этапы (как минимум один)
  has_many :stages, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :stages, allow_destroy: true

  # Контрагент
  belongs_to :contragent
  validates_associated :contragent

  validates :order, uniqueness: { scope: [:year, :code, :order] }

  # номер контракта
  def name
    "#{code}-#{year}-#{order.to_s.rjust(2, "0")}"
  end

  # получаем массив разрешенных параметров запросов на добавление и изменение
  def self.permitted_params
    super | [:contragent_id, :task_kind_id, :status_id, :cost, :deadline_kind] | [stages_attributes: Stage.permitted_params] | [comments_attributes: Comment.permitted_params]
  end
end
