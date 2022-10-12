class CreatePersonNames < ActiveRecord::Migration[6.1]
  def up
    create_table :person_names do |t|
      t.string :surname
      t.string :patrname
      t.string :name

      t.timestamps
    end
    add_index :person_names, [:surname, :name, :patrname], unique: true
  end

  def down
    drop_table :person_names
  end
end
