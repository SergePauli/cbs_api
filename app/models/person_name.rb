# Хранение и учет наборов данных
# для идентификации человека по ФИО
# у женщин ФИО может меняться, потому MutableData

class PersonName < MutableData
  belongs_to :person, inverse_of: :person_names
  belongs_to :naming
  validates_associated :person
  validates_associated :naming
  validates :person, uniqueness: { scope: :naming }
  alias_attribute :state, :naming # для поддержки MutableData
  accepts_nested_attributes_for :naming

  def item
    { id: id, name: naming.head }
  end

  def self.permitted_params
    super | [:person_id, :naming_id, naming_attributes: Naming.permitted_params]
  end
end
