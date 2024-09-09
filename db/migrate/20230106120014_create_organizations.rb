# реквизиты организаций
class CreateOrganizations < ActiveRecord::Migration[6.1]
  def up
    create_table :organizations do |t|
      t.string :name, unique: true, null: false
      t.string :full_name, index: true
      t.string :inn, limit: 10
      t.string :kpp, limit: 9
      t.string :division, limit: 3
      t.string :ogrn, limit: 13
      t.string :okpo, limit: 10
      t.string :oktmo, limit: 11
      t.string :okved, limit: 10
      t.string :okogu, limit: 9
      t.string :okfc, limit: 3
      t.string :okopf, limit: 8
      t.references :ownership, null: false, foreign_key: true
      t.timestamps
    end
    add_index :organizations, [:inn, :kpp, :division], unique: true
  end

  def down
    drop_table :organizations
  end
end
