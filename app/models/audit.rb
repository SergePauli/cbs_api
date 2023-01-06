class Audit < ApplicationRecord
  belongs_to :user
  has_one :person, through: :user

  enum action: [:added, :updated, :removed, :archived, :imported]

  #объекты, которым требуется аудит
  enum obj_type: [:contragent, :contract, :employee]

  validates :obj_uuid, presence: true
  validates :obj_name, presence: true
  validates :obj_type, presence: true
  validates :action, presence: true
  validates :user, presence: true
  validates_associated :user

  def self.action_name(action)
    case action
    when :contragent
      "Контрагент"
    when :contract
      "Контракт"
    when :employee
      "Сотрудник"
    end
  end

  def self.obj_type_name(obj_type)
    case obj_type
    when :added
      "Добавлен"
    when :updated
      "Изменен"
    when :removed
      "Удален"
    when :archived
      "Архив"
    when :imported
      "Импорт"
    end
  end

  # реализация для набора данных head
  def head
    "#{created_at.strftime("%d.%m.%Y %H:%M")} #{Audit.action_name action}: #{Audit.obj_type_name obj_type} #{obj_name}"
  end

  # реализация для набора данных card
  def card
    super.merge({ action: action, obj_uuid: obj_uuid, obj_name: obj_name, obj_type: obj_type, field_name: field_name, detail: detail, before: before, after: after, user: user.item })
  end

  # атрибуты для добавления
  def self.permitted_params
    [:id, :action, :obj_uuid, :obj_name, :obj_type, :field_name, :detail, :before, :after, :user_id, :_destroy]
  end
end
