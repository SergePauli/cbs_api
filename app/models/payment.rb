# Финансовая часть. Платежи по контракту
class Payment < ApplicationRecord
  # аудит изменений
  include Auditable

  # вид платежа: (предоплата, оплата)
  enum payment_kind: [:prepayment, :last_payment]
  validates :payment_kind, presence: true, inclusion: { in: payment_kind.keys }

  # этап
  belongs_to :stage
  validates_associated :stage

  # Формируем имя записи: вид платежа + сумма (пример: "предоплата: 70000.00")
  def name
    "#{I18n.t payment_kind}: #{"%.2f" % amount}"
  end

  # Набор данных card
  def card
    super.merge({ stage: stage.item, payment_kind: payment_kind, amount: amount, payment_at: payment_at, description: description, list_key: list_key })
  end

  def self.permitted_params
    super | [:stage_id, :payment_kind, :amount, :payment_at, :description, :list_key, :_destroy]
  end
end
