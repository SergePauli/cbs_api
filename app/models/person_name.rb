class PersonName < ApplicationRecord
  belongs_to :person
  belongs_to :naming
  validates_associated :person
  validates_associated :naming
  validates :person, uniqueness: { scope: :naming }
  before_validation :ensure_naming_is_unique

  private

  def ensure_naming_is_unique
    if !!naming && !naming.id
      naming_hash = naming.attributes.filter { |k, v| v != nil }
      self.naming = Naming.where(naming_hash).first_or_initialize
    end
  end
end
