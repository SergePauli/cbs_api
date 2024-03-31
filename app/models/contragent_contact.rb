# хранение контактов контрагента
# контакты могут меняться со временем - потому используем MutableData
class ContragentContact < MutableData

  # Не создаем дублей контактов
  include Stateable

  belongs_to :contragent, inverse_of: :contragent_contacts
  belongs_to :contact
  validates_associated :contragent
  validates_associated :contact
  validates :contragent, uniqueness: { scope: :contact }
  alias_attribute :state, :contact # для поддержки MutableData
  accepts_nested_attributes_for :contact

  def type
    contact.type
  end

  def item
    super.merge({ description: description })
  end

  def edit
    super.merge({ contragent_id: contragent_id, contact_attributes: contact.edit })
  end

  def self.permitted_params
    super | [:contragent_id, :contact_id, :description] | [contact_attributes: Contact.permitted_params]
  end
end
