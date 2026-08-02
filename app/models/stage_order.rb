# Поставки к контракту(этапу)
class StageOrder < MutableData
  # аудит изменений
  include Auditable

  belongs_to :stage, optional: true
  belongs_to :isecurity_tool
  belongs_to :order, optional: true
  
  validates_associated :isecurity_tool
  
  

  accepts_nested_attributes_for :isecurity_tool
  accepts_nested_attributes_for :order
  

  alias_attribute :state, :isecurity_tool # для поддержки MutableData

  def head
    first_part = stage.nil? ? "" : stage.name
    order_part = order.nil? ? "" : " "+order.name
    first_part = first_part + order_part
    second_part = isecurity_tool.nil? ? "" : " "+isecurity_tool.name
    second_part += amount.nil? ? "" : " к-во: "+(amount.to_i).to_s  
    first_part + second_part
  end 
  
  def name
   head
  end

  

  def card
    super.merge({ stage: stage.item, severity: severity, isecurity_tool: isecurity_tool.item,  order_status: order.item, amount: amount, cost: cost, description: description })
  end

  def self.permitted_params
    super | [:stage_id, :severity, :isecurity_tool_id, :amount, :price_cost, :cost, :order_id, :description] | [isecurity_tool_attributes: IsecurityTool.permitted_params] 
  end
end
