# данные этапа
class CreateStages < ActiveRecord::Migration[6.1]
  def up
    create_table :stages do |t|
      t.references :contract, null: false, foreign_key: true, comment: "контракт"
      t.references :task_kind, null: false, foreign_key: true, comment: "тип работы"
      t.references :status, foreign_key: true, comment: "статус"
      t.integer :priority, null: false, default: 0, comment: "очередность этапа, если 0,то договор - обычный"
      t.float :cost, comment: "сумма этапа"
      t.date :deadline, comment: "срок выполнения"
      t.date :funded_at, comment: "дата бухгалтерского закрытия"
      t.date :completed_at, comment: "дата закрытия"
      t.integer :deadline_kind, comment: "вид срока"
      t.integer :duration, comment: "время выполнения в днях"
      t.date :sended_at, comment: "дата отправки документации"
      t.boolean :is_sended, comment: "документы высланы"
      t.date :ride_out_at, comment: "дата выезда"
      t.boolean :is_ride_out, comment: "признак выезда к контрагенту"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :stages
  end
end