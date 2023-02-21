class CreateStagePerformers < ActiveRecord::Migration[6.1]
  def up
    create_table :stage_performers do |t|
      t.references :stage, null: false, foreign_key: true, comment: "этап"
      t.references :performer, null: false, foreign_key: true, comment: "исполнитель"

      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
    add_index :stage_performers, [:performer_id, :stage_id], unique: true
  end

  def down
    drop_table :stage_performers
  end
end
