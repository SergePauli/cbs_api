class PersonAddress < ApplicationRecord
  belongs_to :person
  belongs_to :address
  validates_associated :person
  validates_associated :address
  validates :person, uniqueness: { scope: :address }
end
