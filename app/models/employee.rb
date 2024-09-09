class Employee < MutableData
  # аудит изменений
  include Auditable

  belongs_to :contragent, inverse_of: :employees
  belongs_to :person
  belongs_to :position
  validates_associated :contragent
  validates_associated :person
  validates_associated :position
  validates :contragent, uniqueness: { scope: [:person, :position] }
  alias_attribute :state, :position # для поддержки MutableData
  alias_attribute :main_model, :contragent # для поддержки обновления кэша модели-владельца
  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :position

  def name
    person.name
  end

  def head
    tmp = position.blank? ? person.name : "#{person.name}, #{position.name}"
    tmp = "*" + tmp unless used
    tmp
  end

  def item
    { id: id, priority: priority, name: name, full_name: person.person_name.naming.head, position: position.name, contacts: person.person_contacts.filter { |el| el.used }.map { |el| el.custom_data(:item) } || [], description: description }
  end

  def card
    super.merge({description: description, person: person.card, position: position.item, contragent: contragent.item, audits: audits.map { |el| el.item } || [] })
  end

  def edit
    super.merge({list_key: list_key, description: description, person: person.edit, position: position.nil? ? nil : position.item, contragent: contragent.nil? ? nil : contragent.item })
  end

  def self.permitted_params
    super | [:contragent_id, :person_id, :position_id, :description] | [person_attributes: Person.permitted_params] | [position_attributes: Position.permitted_params]
  end

  ransack_alias :person_name, :person_person_name_naming_name_or_person_person_name_naming_surname_or_person_person_name_naming_patrname
end
