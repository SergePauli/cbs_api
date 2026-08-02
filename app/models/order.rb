class Order < ApplicationRecord
  # аудит изменений
  include Auditable

  belongs_to :contragent
  belongs_to :order_status
  has_many :stage_orders
    

  
  validates_associated :order_status
  accepts_nested_attributes_for :stage_orders
  
  def head
   base_part = order_number.present? ? order_number : "Заказ c ID:#{id}"
   second_part = contragent.nil? ? "" : " в "+contragent.name
   third_part =  ordered_at.nil? ? "" : " от "+ordered_at.strftime("%d.%m.%Y")
   base_part + second_part + third_part
  end

  def name
    head
  end

  # реализация для набора данных card
  def card
    super.merge({ order_number: order_number, order_status: order_status.item, contragent: contragent.item, requested_at: to_date_str(requested_at), ordered_at: to_date_str(ordered_at), payment_at: to_date_str(payment_at), received_at: to_date_str(received_at), description: description, cost: cost, stage_orders: stage_orders.map { |el| el.card } || [] })
  end

  def self.permitted_params
    super | [:order_number, :requested_at, :ordered_at, :payment_at, :received_at, :description, :cost, :order_status_id, :contragent_id] | [stage_orders_attributes: StageOrder.permitted_params]
  end
end