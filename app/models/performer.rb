# список исполнителей для отделов
class Performer < MutableData
  # аудит изменений
  include Auditable

  belongs_to :department
  belongs_to :person
  belongs_to :position
  validates_associated :department
  validates_associated :person
  validates_associated :position
  validates :position, uniqueness: { scope: [:person, :department] }
  alias_attribute :state, :position # для поддержки MutableData
  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :position

  def name
    person.name
  end

  def head
    tmp = "#{person.name}, #{position.name}"
    tmp = "*" + tmp unless used
    tmp
  end

  def item
    { id: id, priority: priority, name: name, position: position.name, contacts: person.person_contacts.filter { |el| el.used }.map { |el| el.custom_data(:item) } || [] }
  end

  def card
    super.merge({ priority: priority, description: description, person: person.card, position: position.item, department: department.item, audits: audits.map { |el| el.item } || [] })
  end

  def self.permitted_params
    super | [:department_id, :person_id, :position_id, :description] | [person_attributes: Person.permitted_params] | [position_attributes: Position.permitted_params]
  end
end
