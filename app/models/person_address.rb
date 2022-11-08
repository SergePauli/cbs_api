# хранение адресов жительства человека
# адрес может меняться - потому используем MutableData
class PersonAddress < MutableData
  belongs_to :person
  belongs_to :address
  validates_associated :person
  validates_associated :address
  validates :person, uniqueness: { scope: :address }
  alias_attribute :state, :address # для поддержки MutableData
end
