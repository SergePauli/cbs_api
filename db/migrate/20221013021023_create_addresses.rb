class CreateAddresses < ActiveRecord::Migration[6.1]
  def up
    create_table :addresses do |t|
      t.string :value
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
    add_index :addresses, [:area_id, :value], unique: true
  end

  def down
    drop_table :addresses
  end
end
