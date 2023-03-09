class Task < MutableData
  belongs_to :stage
  belongs_to :task_kind
  validates_associated :stage
  validates_associated :task_kind
  validates :stage, uniqueness: { scope: [:stage, :task_kind] }
  alias_attribute :state, :task_kind # для поддержки MutableData
  accepts_nested_attributes_for :task_kind

  def name
    task_kind.name
  end

  def card
    super.merge({ stage: stage.item, task_kind: task_kind.item })
  end

  def self.permitted_params
    super | [:stage_id, :task_kind_id] | [task_kind_attributes: Task_kind.permitted_params]
  end
end
