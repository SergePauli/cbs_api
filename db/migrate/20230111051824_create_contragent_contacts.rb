class CreateContragentContacts < ActiveRecord::Migration[6.1]
  def up
    create_table :contragent_contacts do |t|
      t.references :contragent, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true
      t.string :description
      t.uuid :list_key, null: false
      t.timestamps
    end
    add_index :contragent_contacts, [:contragent_id, :contact_id], unique: true
  end

  def down
    drop_table :contragent_contacts
  end
end
