# Финансовая часть. Платежи по контракту
class Payment < ApplicationRecord

  # вид платежа: (предоплата, оплата)
  enum payment_kind: [:prepayment, :last_payment]
  validates :payment_kind, presence: true, inclusion: { in: payment_kinds.keys }

  # этап
  belongs_to :stage
  validates_associated :stage

  # Формируем имя записи: дата + вид платежа (пример: "10.10.2023 - предоплата")
  def name
    "#{payment_at.strftime("%d.%m.%Y")}-#{I18n.t payment_kind}"
  end

  # Набор данных card
  def card
    super.merge({ stage: stage.item, payment_kind: payment_kind, payment_at: payment_at, description: description, list_key: list_key })
  end

  def self.permitted_params
    super | [:stage_id, :payment_kind, :payment_at, :description, :list_key, :_destroy]
  end
end
