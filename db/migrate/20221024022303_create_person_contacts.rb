class CreatePersonContacts < ActiveRecord::Migration[6.1]
  def up
    create_table :person_contacts do |t|
      t.references :person, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true
      t.timestamps
    end
    add_index :person_contacts, :priority
    add_index :person_contacts, [:person_id, :contact_id], unique: true
  end

  def down
    drop_table :person_contacts
  end
end
