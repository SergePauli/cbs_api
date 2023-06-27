class CreateOwnerships < ActiveRecord::Migration[6.1]
  def up
    create_table :ownerships do |t|
      t.string :name, null: false
      t.string :full_name
      t.string :okopf
      t.timestamps
    end
    add_index :ownerships, :name, unique: true
  end

  def down
    drop_table :ownerships
  end
end
