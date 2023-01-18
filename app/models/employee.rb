class Employee < MutableData
  belongs_to :contragent, inverse_of: :employee
  belongs_to :person
  belongs_to :position, optional: true
  validates_associated :contragent
  validates_associated :person
  validates_associated :position
  validates :contragent, uniqueness: { scope: :person }
  alias_attribute :state, :person # для поддержки MutableData
  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :position

  def type
    contact.type
  end

  def name
    "#{person.name} #{position.name}"
  end

  def card
    super.merge({ description: description, person: person.card, position: position.item })
  end

  def self.permitted_params
    super | [:contragent_id, :person_id, :description, person_attributes: Person.permitted_params, position_attributes: Position.permitted_params]
  end
end
