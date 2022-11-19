class CreatePositions < ActiveRecord::Migration[6.1]
  def up
    create_table :positions do |t|
      t.string :name
      t.string :def_statuses
      t.string :def_contract_types
      t.timestamps
    end
    add_index :positions, :name, unique: true
  end

  def down
    drop_table :positions
  end
end
