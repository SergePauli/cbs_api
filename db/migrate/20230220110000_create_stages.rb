# данные этапа
class CreateStages < ActiveRecord::Migration[6.1]
  def up
    create_table :stages do |t|
      t.references :contract, null: false, foreign_key: true, comment: "контракт"
      t.references :task_kind, null: false, foreign_key: true, comment: "тип работы"
      t.references :status, foreign_key: true, comment: "статус"
      t.integer :priority, null: false, default: 0, comment: "очередность этапа, если 0,то договор - обычный"
      t.float :cost, comment: "сумма этапа"
      t.date :deadline_at, comment: "срок выполнения"
      t.date :funded_at, comment: "дата бухгалтерского закрытия"
      t.date :invoice_at, comment: "дата выставления счета на оплату"
      t.date :completed_at, comment: "дата закрытия"
      t.integer :deadline_kind, comment: "вид срока"
      t.integer :payment_deadline_kind, comment: "вид срока оплаты"
      t.integer :payment_duration, comment: "дней на оплату"
      t.date :payment_deadline_at, comment: "срок оплаты"
      t.integer :duration, comment: "время выполнения в днях"
      t.date :sended_at, comment: "дата отправки документации"
      t.boolean :is_sended, comment: "документы высланы"
      t.date :ride_out_at, comment: "дата выезда"
      t.boolean :is_ride_out, comment: "признак выезда к контрагенту"
      t.boolean :used, null: false, default: true, comment: "признак актуальности информации"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :stages
  end
end
