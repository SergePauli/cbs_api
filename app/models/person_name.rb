class PersonName < ApplicationRecord
  validates :name, presence: true
  validates :surname, presence: true
  validates :surname, uniqueness: { scope: [:name, :patrname] }
end
