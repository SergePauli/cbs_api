class CreateContractNumbers < ActiveRecord::Migration[6.1]
  def up
    create_table :contract_numbers do |t|
      t.references :contract, null: false, foreign_key: true, comment: "контракт"
      t.string :number, null: false, index: true, comment: "полный номер контракта"
      t.string :LinkFileProtocol, comment: "ссылка на скан"
      t.string :LinkFileScan, comment: "ссылка на скан"
      t.string :LinkFileDoc, comment: "ссылка на текст"
      t.string :LinkFileZip, comment: "ссылка на архив"
      t.boolean :used, null: false, default: true, comment: "признак отображения как номера контракта"
      t.integer :additional_number, comment: "номер доп.соглашения"
      t.boolean :is_present, comment: "признак наличия подписаного оригинала контракта"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :contract_numbers
  end
end
