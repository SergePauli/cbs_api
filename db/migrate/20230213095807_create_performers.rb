class CreatePerformers < ActiveRecord::Migration[6.1]
  def up
    create_table :performers do |t|
      t.references :person, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.references :position, foreign_key: true
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true
      t.string :description
      t.uuid :list_key, null: false
      t.timestamps
    end
    add_index :performers, [:department_id, :person_id, :position_id], unique: true
  end

  def down
    drop_table :performers
  end
end
