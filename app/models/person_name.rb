# Хранение и учет наборов данных
# для идентификации человека по ФИО
# у женщин ФИО может меняться, потому MutableData

class PersonName < MutableData
  # только одна запись может быть используемой (актуальной)
  include Singleable

  # Не создаем дублей ФИО
  include Stateable

  belongs_to :person, inverse_of: :person_names
  belongs_to :naming
  validates_associated :person
  validates_associated :naming
  validates :person, uniqueness: { scope: :naming }
  alias_attribute :state, :naming # для поддержки MutableData
  alias_attribute :main_model_id, :person_id # для поддержки Singleable

  accepts_nested_attributes_for :naming

  def item
    { id: id, name: naming.head }
  end

  def edit
    { id: id, used: used, person_id: person_id, naming: naming.edit, name: naming.head }
  end

  def self.permitted_params
    super | [:person_id, :naming_id] | [naming_attributes: Naming.permitted_params]
  end
end
