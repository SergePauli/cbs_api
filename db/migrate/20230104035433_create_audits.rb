class CreateAudits < ActiveRecord::Migration[6.1]
  def up
    create_table :audits do |t|
      t.references :auditable, polymorphic: true, index: true
      t.integer :action, limit: 1, index: true, null: false
      t.string :auditable_field
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
