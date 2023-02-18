# виды задач по контракту
class CreateTaskKinds < ActiveRecord::Migration[6.1]
  def up
    create_table :task_kinds do |t|
      t.string :name, unique: true
      t.string :code, limit: 2, index: true
      t.string :description
      t.float :cost
      t.integer :duration
      t.timestamps
    end
  end

  def down
    drop_table :task_kinds
  end
end
