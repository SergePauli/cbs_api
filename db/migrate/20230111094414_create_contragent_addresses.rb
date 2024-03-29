class CreateContragentAddresses < ActiveRecord::Migration[6.1]
  def up
    create_table :contragent_addresses do |t|
      t.references :contragent, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.integer :priority, null: false, default: 1, index: true
      t.boolean :used, null: false, default: true
      t.integer :kind, limit: 1, index: true, null: false, default: 0
      t.uuid :list_key, null: false
      t.timestamps
    end
  end

  def down
    drop_table :contragent_addresses
  end
end
