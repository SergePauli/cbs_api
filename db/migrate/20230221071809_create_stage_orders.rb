# заказы поставки
class CreateStageOrders < ActiveRecord::Migration[6.1]
  def up
    create_table :stage_orders do |t|
      t.references :stage, null: false, foreign_key: true, comment: "этап"
      t.references :isecurity_tool, null: false, foreign_key: true, comment: "СЗИ, товар"
      t.references :status, null: false, foreign_key: true, comment: "статус поставки"
      t.references :contragent, null: false, foreign_key: true, comment: "поставщик"
      t.float :amount, comment: "колличество"
      t.date :requested_at, comment: "дата запроса счета"
      t.string :order_number, comment: "счет на поставку"
      t.date :ordered_at, comment: "дата счета"
      t.date :payment_at, comment: "дата оплаты счета"
      t.date :received_at, comment: "дата прихода"
      t.string :description, comment: "примечание"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :stage_orders
  end
end
