class CreateContragentOrganizations < ActiveRecord::Migration[6.1]
  def up
    create_table :contragent_organizations do |t|
      t.references :contragent, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.integer :priority, null: false, default: 1
      t.boolean :used, null: false, default: true
      t.timestamps
    end
    add_index :contragent_organizations, [:contragent_id, :organization_id], unique: true, name: "by_contr_org_ids"
    add_index :contragent_organizations, [:used, :organization_id], unique: true, name: "by_used_org_ids"
  end

  def down
    drop_table :contragent_organizations
  end
end
