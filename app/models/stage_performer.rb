class StagePerformer < MutableData
  # аудит изменений
  include Auditable

  belongs_to :stage
  belongs_to :performer
  validates_associated :stage
  validates_associated :performer
  validates :stage, uniqueness: { scope: [:stage, :performer] }
  alias_attribute :state, :performer # для поддержки MutableData
  accepts_nested_attributes_for :performer

  def name
    performer.name
  end

  def card
    super.merge({ stage: stage.item, performer: performer.item })
  end

  def self.permitted_params
    super | [:stage_id, :performer_id] | [performer_attributes: Performer.permitted_params]
  end
end
