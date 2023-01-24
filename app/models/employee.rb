class Employee < MutableData
  belongs_to :contragent, inverse_of: :employees
  belongs_to :person
  belongs_to :position
  validates_associated :contragent
  validates_associated :person
  validates_associated :position
  validates :contragent, uniqueness: { scope: [:person, :position] }
  alias_attribute :state, :position # для поддержки MutableData
  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :position

  def name
    person.name
  end

  def head
    "#{person.name}, #{position.name}"
  end

  def item
    { id: id, priority: priority, name: name, position: position.name, contacts: person.person_contacts.filter { |el| el.used }.map { |el| el.custom_data(:item) } || [] }
  end

  def card
    super.merge({ priority: priority, description: description, person: person.card, position: position.item, contragent: contragent.item })
  end

  def self.permitted_params
    super | [:contragent_id, :person_id, :position_id, :description, person_attributes: Person.permitted_params, position_attributes: Position.permitted_params]
  end
end
