class CreateDepartments < ActiveRecord::Migration[6.1]
  def up
    create_table :departments do |t|
      t.string :name
      t.string :def_statuses
      t.string :def_contracts_types

      t.timestamps
    end
    add_index :departments, :name, unique: true
  end

  def down
    drop_table :departments
  end
end
