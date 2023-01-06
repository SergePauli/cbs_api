class CreateAudits < ActiveRecord::Migration[6.1]
  def up
    create_table :audits do |t|
      t.string :obj_uuid, index: true, null: false
      t.integer :action, limit: 1, index: true, null: false
      t.integer :obj_type, limit: 1, index: true, null: false
      t.string :obj_name, null: false
      t.string :field_name
      t.string :detail
      t.string :before
      t.string :after
      t.belongs_to :user, index: true
      t.timestamps
    end
  end

  def down
    drop_table :audits
  end
end
