class PersonName < ApplicationRecord
  belongs_to :person
  belongs_to :naming
  validates_associated :person
  validates_associated :naming
  validates :person, uniqueness: { scope: :naming }
end
