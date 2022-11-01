class PersonContact < ApplicationRecord
  belongs_to :person
  belongs_to :contact
  validates_associated :person
  validates_associated :contact
  validates :person, uniqueness: { scope: :contact }

  def type
    contact.type
  end
end
