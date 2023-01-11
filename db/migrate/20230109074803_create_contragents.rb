class CreateContragents < ActiveRecord::Migration[6.1]
  def up
    create_table :contragents do |t|
      t.uuid :obj_uuid, unique: true, null: false, default: -> { "gen_random_uuid()" }
      t.integer :obj_type, limit: 1, index: true, null: false
      t.string :description
      t.belongs_to :person
      t.timestamps
    end
  end

  def down
    drop_table :contragents
  end
end
