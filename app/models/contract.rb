#главный класс приложения
class Contract < ApplicationRecord
  # используется режим сроков
  include Deadlineable

  # аудит изменений
  include Auditable

  # Комментирование
  include Commentable

  # Весь документо-оборот по контракту
  has_many :revisions, -> { order("priority ASC") }, inverse_of: :revision, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :revisions, allow_destroy: true

  # Этапы (как минимум один)
  has_many :stages, -> { order("priority ASC") }, inverse_of: :stage, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :stages, allow_destroy: true

  # номер контракта
  def name
    "#{code}-#{year}-#{order.to_s.rjust(2, "0")}"
  end
end
