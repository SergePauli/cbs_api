# хранение контактов человека
# контакты могут меняться со временем - потому используем MutableData
class PersonContact < MutableData
  belongs_to :person
  belongs_to :contact
  validates_associated :person
  validates_associated :contact
  validates :person, uniqueness: { scope: :contact }
  alias_attribute :state, :contact # для поддержки MutableData

  def type
    contact.type
  end
end
