class Comment < ApplicationRecord
  # Персонализация авторства
  include Personable

  belongs_to :commentable, polymorphic: true
  belongs_to :profile
  has_one :user, through: :profile
  has_one :department, through: :profile

  validates :content, presence: true
  validates_associated :profile

  # атрибуты для добавления
  def self.permitted_params
    super | [:content, :profile_id, :_destroy]
  end
end
