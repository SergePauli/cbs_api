# исполнители работы этапа
class CreatePerformers < ActiveRecord::Migration[6.1]
  def up
    create_table :performers do |t|
      t.references :stage, null: false, foreign_key: true, comment: "этап"
      t.references :employee, null: false, foreign_key: true, comment: "исполнитель"
      t.integer :priority, index: true, null: false, default: 0, comment: "порядок в списке"
      t.boolean :used, null: false, default: true, comment: "признак использования"
      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
    add_index :performers, [:employee_id, :stage_id], unique: true
  end

  def down
    drop_table :performers
  end
end
