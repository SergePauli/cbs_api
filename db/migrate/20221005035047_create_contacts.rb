class CreateContacts < ActiveRecord::Migration[6.1]
  def up
    create_table :contacts do |t|
      t.string :value, limit: 250, null: false
      t.string :type, limit: 100, null: false
      t.timestamps
    end
    add_index :contacts, [:value, :type], unique: true
  end

  def down
    drop_table :contacts
  end
end
