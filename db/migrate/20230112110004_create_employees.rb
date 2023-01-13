class CreateEmployees < ActiveRecord::Migration[6.1]
  def up
    create_table :employees do |t|
      t.references :person, null: false, foreign_key: true
      t.references :contragent, null: false, foreign_key: true
      t.references :position, foreign_key: true
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true
      t.string :description
      t.timestamps
    end
  end

  def down
    drop_table :employees
  end
end
