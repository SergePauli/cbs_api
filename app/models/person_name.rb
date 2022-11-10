# Хранение и учет наборов данных
# для идентификации человека по ФИО
# у женщин ФИО может меняться, потому MutableData

class PersonName < MutableData
  belongs_to :person
  belongs_to :naming
  validates_associated :person
  validates_associated :naming
  validates :person, uniqueness: { scope: :naming }
  alias_attribute :state, :naming # для поддержки MutableData

  def item
    { id: id, name: naming.head, used: used }
  end
end
