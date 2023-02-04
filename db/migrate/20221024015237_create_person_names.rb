class CreatePersonNames < ActiveRecord::Migration[6.1]
  def up
    create_table :person_names do |t|
      t.references :person, null: false, foreign_key: true
      t.references :naming, null: false, foreign_key: true
      t.boolean :used, null: false, default: true
      t.uuid :list_key, null: false
      t.timestamps
    end
    add_index :person_names, [:person_id, :naming_id], unique: true
  end

  def down
    drop_table :person_names
  end
end
