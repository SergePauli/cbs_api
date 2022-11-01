class CreateNamings < ActiveRecord::Migration[6.1]
  def up
    create_table :namings do |t|
      t.string :surname
      t.string :patrname
      t.string :name

      t.timestamps
    end
    add_index :namings, [:surname, :name, :patrname], unique: true
  end

  def down
    drop_table :namings
  end
end
