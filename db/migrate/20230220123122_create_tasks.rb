# задачи этапа
class CreateTasks < ActiveRecord::Migration[6.1]
  def up
    create_table :tasks do |t|
      t.references :stage, null: false, foreign_key: true, comment: "этап"
      t.references :task_kind, null: false, foreign_key: true, comment: "тип работы, задачи"
      t.integer :priority, null: false, default: 0
      t.boolean :used, null: false, default: true
      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :tasks
  end
end
