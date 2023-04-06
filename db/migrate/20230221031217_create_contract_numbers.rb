class CreateContractNumbers < ActiveRecord::Migration[6.1]
  def up
    create_table :contract_numbers do |t|
      t.references :contract, null: false, foreign_key: true, comment: "контракт"
      t.string :number, null: false, index: true, comment: "полный номер контракта"
      t.string :protocol_link, comment: "ссылка на протокол"
      t.string :scan_link, comment: "ссылка на скан"
      t.string :doc_link, comment: "ссылка на текст"
      t.string :zip_link, comment: "ссылка на архив"
      t.boolean :used, null: false, default: true, comment: "признак отображения как номера контракта"
      t.integer :priority, comment: "номер доп.соглашения"
      t.boolean :is_present, comment: "признак наличия подписаного оригинала контракта"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :contract_numbers
  end
end
