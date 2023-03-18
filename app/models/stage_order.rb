# Поставки к контракту(этапу)
class StageOrder < MutableData
  # аудит изменений
  include Auditable

  belongs_to :stage
  belongs_to :isecurity_tool
  belongs_to :organization
  belongs_to :order_status
  validates_associated :stage
  validates_associated :isecurity_tool
  validates_associated :order_status
  validates_associated :organization
  validates :stage, uniqueness: { scope: [:stage, :isecurity_tool, :organization] }

  accepts_nested_attributes_for :isecurity_tool
  accepts_nested_attributes_for :organization
  accepts_nested_attributes_for :order_status

  alias_attribute :state, :isecurity_tool # для поддержки MutableData

  def name
    isecurity_tool.name
  end

  def card
    super.merge({ stage: stage.item, isecurity_tool: isecurity_tool.item, organization: organization.item, order_status: order_status.item, amount: amount, requested_at: requested_at, order_number: order_number, ordered_at: ordered_at, payment_at: payment_at, received_at: received_at, description: description })
  end

  def self.permitted_params
    super | [:stage_id, :isecurity_tool_id, :organization_id, :amount, :requested_at, :order_number, :ordered_at, :payment_at, :received_at, :description] | [isecurity_tool_attributes: IsecurityTool.permitted_params] | [organization_attributes: Organization.permitted_params] | [order_status_attributes: OrderStatus.permitted_params]
  end
end
