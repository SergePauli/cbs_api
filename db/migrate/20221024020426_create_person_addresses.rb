class CreatePersonAddresses < ActiveRecord::Migration[6.1]
  def up
    create_table :person_addresses do |t|
      t.references :person, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true

      t.timestamps
    end
    add_index :person_addresses, :priority
    add_index :person_addresses, [:person_id, :address_id], unique: true
  end

  def down
    drop_table :person_addresses
  end
end
