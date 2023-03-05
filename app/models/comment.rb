class Comment < ApplicationRecord
  # Персонализация авторства
  include Personable

  belongs_to :commentable, polymorphic: true
  belongs_to :profile
  has_one :user, through: :profile
  has_one :department, through: :profile

  validates :content, presence: true
  validates_associated :profile

  def commentable_type_local
    I18n.t commentable_type
  end

  # реализация для набора данных head
  def head
    "#{created_at.strftime("%d.%m.%Y %H:%M")} #{person.initials}"
  end

  # реализация для набора данных :item
  def item
    super.merge({ commentable: commentable.item, department: department.item, content: content })
  end

  # реализация для набора данных card
  def card
    super.merge({ content: content, commentable: commentable.item, commentable_type: commentable_type, profile: profile.item, user: user.item, person: person.item, department: department.item })
  end

  # атрибуты для добавления
  def self.permitted_params
    super | [:content, :profile_id, :_destroy]
  end
end
