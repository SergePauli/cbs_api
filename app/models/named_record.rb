class NamedRecord < ApplicationRecord
  self.abstract_class = true
  validates :name, presence: true
  validates :name, uniqueness: true

  def self.permitted_params
    super | [:name]
  end
end
