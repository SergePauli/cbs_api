# хранение контактов человека
# контакты могут меняться со временем - потому используем MutableData
class PersonContact < MutableData
  
  # Не создаем дублей контактов
  include Stateable

  belongs_to :person, inverse_of: :person_contacts
  belongs_to :contact
  validates_associated :person
  validates_associated :contact
  validates :person, uniqueness: { scope: :contact }
  alias_attribute :state, :contact # для поддержки MutableData
  
  accepts_nested_attributes_for :contact

  def type
    contact.type
  end

  def item
    super.merge(type: type)
  end

  def edit
    super.merge({ person_id: person_id, contact: contact.edit })
  end

  def self.permitted_params
    super | [:person_id, :contact_id] | [contact_attributes: Contact.permitted_params]
  end
end
