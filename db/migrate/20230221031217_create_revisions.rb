# таблица для хранения ссылок на документы по контракту
class CreateRevisions < ActiveRecord::Migration[6.1]
  def up
    create_table :revisions do |t|
      t.references :contract, null: false, foreign_key: true, comment: "ссылка на контракт"
      t.string :protocol_link, comment: "ссылка на протокол"
      t.string :scan_link, comment: "ссылка на скан"
      t.string :doc_link, comment: "ссылка на текст"
      t.string :zip_link, comment: "ссылка на архив"
      t.boolean :used, null: false, default: true, comment: "признак использования"
      t.integer :priority, comment: "номер ревизии или доп.соглашения"
      t.boolean :is_present, comment: "признак наличия подписаного оригинала"
      t.boolean :is_signed, comment: "признак подписания документа"
      t.string :description, comment: "описание ревизии или Доп-а"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
    add_index :revisions, [:contract_id, :priority], unique: true
  end

  def down
    drop_table :revisions
  end
end
