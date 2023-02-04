class CreateProfiles < ActiveRecord::Migration[6.1]
  def up
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :position, null: false, foreign_key: true
      t.references :department, foreign_key: true
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true
      t.string :statuses
      t.string :contracts_types
      t.uuid :list_key, null: false
      t.timestamps
    end
    add_index :profiles, :priority
  end

  def down
    drop_table :profiles
  end
end
