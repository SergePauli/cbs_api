class Audit < ApplicationRecord
  belongs_to :auditable, polymorphic: true
  belongs_to :user
  has_one :person, through: :user

  enum action: [:added, :updated, :removed, :archived, :imported]

  validates :action, presence: true, inclusion: { in: actions.keys }
  validates :user, presence: true
  validates_associated :user

  def auditable_type_local
    I18n.t auditable_type
  end

  def action_name_local
    I18n.t action
  end

  # реализация для набора данных head
  def head
    "#{created_at.strftime("%d.%m.%Y %H:%M")} #{action_name_local}: #{auditable_type_local} #{auditable.head}"
  end

  # реализация для набора данных card
  def card
    super.merge({ action: action, auditable: auditable.head, auditable_type: auditable_type, auditable_field: auditable_field, detail: detail, before: before, after: after, user: user.item })
  end

  # атрибуты для добавления
  def self.permitted_params
    [:id, :action, :obj_name, :auditable_field, :detail, :before, :after, :user_id, :_destroy]
  end
end
