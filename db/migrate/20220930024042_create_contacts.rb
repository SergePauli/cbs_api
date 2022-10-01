class CreateContacts < ActiveRecord::Migration[6.1]
  def up
    create_table :contacts do |t|
      t.string :value
      t.integer :priority, index: true
      t.boolean :using
      t.references :ContactType, null: false, foreign_key: true

      t.timestamps
    end
  end

  def down
    drop_table :contacts
  end
end
