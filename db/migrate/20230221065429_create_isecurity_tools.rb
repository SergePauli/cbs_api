# справочник СЗИ
class CreateIsecurityTools < ActiveRecord::Migration[6.1]
  def up
    create_table :isecurity_tools do |t|
      t.string :name, unique: true, null: false, comment: "наименование"
      t.string :unit, null: false, comment: "ед. измерения"
      t.integer :priority, index: true, null: false, default: 0, comment: "порядок в списке"
      t.boolean :used, null: false, default: true, comment: "признак использования"
      t.timestamps
    end
  end

  def down
    drop_table :isecurity_tools
  end
end
