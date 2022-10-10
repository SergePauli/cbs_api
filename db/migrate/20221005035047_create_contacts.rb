class CreateContacts < ActiveRecord::Migration[6.1]
  def up
    create_table :contacts do |t|
      t.string :value, limit: 250, null: false
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true
      t.string :type, limit: 100, null: false
      t.timestamps
    end
    add_index :contacts, :priority
  end

  def down
    drop_table :contacts
  end
end
