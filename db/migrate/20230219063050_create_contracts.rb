# Основная таблица (контракты)
class CreateContracts < ActiveRecord::Migration[6.1]
  def up
    create_table :contracts do |t|
      t.references :contragent, null: false, foreign_key: true, comment: "контрагент"
      t.references :task_kind, null: false, foreign_key: true, comment: "тип контракта"
      t.references :status, null: false, foreign_key: true, comment: "статус"
      t.integer :order, null: false, comment: "сквозной номер, относительно года и типа"
      t.integer :year, null: false, comment: "год контракта"
      t.string :code, null: false, limit: 2, comment: "код типа контракта"
      t.boolean :governmental, null: false, default: false, comment: "госконтракт?"
      t.date :signed_at, comment: "дата контракта (подписания)"
      t.date :deadline_at, comment: "срок завершения контракта"
      t.date :closed_at, comment: "дата закрытия контракта"
      t.string :external_number, comment: "внешний номер"

      t.timestamps
    end
    add_index :contracts, [:year, :code, :order], unique: true
  end

  def down
    drop_table :contracts
  end
end
