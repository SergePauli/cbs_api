# This migration comes from cbs_api (originally 20230221071810)
# заказ на поставку СЗИ
class CreateOrders < ActiveRecord::Migration[6.1]
  def up
    create_table :orders do |t|
      t.string :order_number, comment: "счет на поставку"
      t.references :order_status, null: false, comment: "статус поставки"
      t.references :contragent, null: false, foreign_key: true, comment: "поставщик"
      t.float :cost, precision: 10, scale: 2, comment: "стоимость"
      t.date :requested_at, comment: "дата запроса счета"
      t.date :ordered_at, comment: "дата счета"
      t.date :payment_at, comment: "дата оплаты счета"
      t.date :received_at, comment: "дата прихода"
      t.string :description, comment: "примечание"
      t.timestamps
    end
  end

  def down
    drop_table :orders
  end
end
