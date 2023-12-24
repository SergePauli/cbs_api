class Audit < ApplicationRecord

  # Персонализация авторства
  include Personable

  belongs_to :auditable, polymorphic: true
  belongs_to :user

  enum action: [:added, :updated, :removed, :archived, :imported]

  validates :action, presence: true, inclusion: { in: actions.keys }
  validates :user, presence: true
  validates_associated :user

  def auditable_type_local
    I18n.t auditable_type
  end

  def auditable_field_local
    I18n.t auditable_field
  end

  def action_name_local
    I18n.t action
  end

  # реализация для набора данных head
  def head
    "#{created_at.strftime("%d.%m.%Y %H:%M")} #{action_name_local}: #{auditable_field.blank? ? auditable_type_local : auditable_field_local + " в " + auditable_type_local} #{auditable.nil? ? "" : auditable.head}"
  end

  # реализация для набора данных card
  def card
    super.merge({ action: action, when: "#{created_at.strftime("%d.%m.%Y %H:%M")}", where: "#{auditable_type_local}", what: "#{auditable.nil? ? "" : auditable.head}", field: "#{auditable_field.blank? ? nil : auditable_field_local}",
                  detail: detail, after: after, before: before, user: user.item, person: person.item })
  end

  # атрибуты для добавления
  def self.permitted_params
    super | [:action, :auditable_field, :detail, :before, :after, :user_id, :_destroy]
  end
end
