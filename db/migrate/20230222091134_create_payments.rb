# Платежи этапа
class CreatePayments < ActiveRecord::Migration[6.1]
  def up
    create_table :payments do |t|
      t.references :stage, null: false, foreign_key: true, comment: "этап"
      t.integer :payment_kind, comment: "вид платежа", null: false
      t.date :payment_at, comment: "дата платежа"
      t.float :amount, comment: "сумма"
      t.string :description, comment: "примечание"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :payments
  end
end
