class Performer < MutableData
  belongs_to :stage
  belongs_to :employee
  validates_associated :stage
  validates_associated :employee
  validates :stage, uniqueness: { scope: [:stage, :employee] }
  alias_attribute :state, :employee # для поддержки MutableData

  def name
    employee.name
  end

  def edit
    super.merge({ employee_id: employee_id, name: name })
  end

  def card
    super.merge({ stage: stage.item, employee: employee.item })
  end

  def self.permitted_params
    super | [:stage_id, :employee_id]
  end
end
