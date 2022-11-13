class CreateAreas < ActiveRecord::Migration[6.1]
  def up
    create_table :areas do |t|
      t.string :name

      t.timestamps
    end
    add_index :areas, :name, unique: true
  end

  def down
    drop_table :areas
  end
end
