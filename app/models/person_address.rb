# хранение адресов жительства человека
# адрес может меняться - потому используем MutableData
class PersonAddress < MutableData
  belongs_to :person, inverse_of: :person_addresses
  belongs_to :address
  validates_associated :person
  validates_associated :address
  validates :person, uniqueness: { scope: :address }
  alias_attribute :state, :address # для поддержки MutableData
  accepts_nested_attributes_for :address

  def self.permitted_params
    super | [:person_id, :address_id] | [address_attributes: Address.permitted_params]
  end
end
