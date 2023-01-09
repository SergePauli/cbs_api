# реквизиты организаций
class CreateOrganizations < ActiveRecord::Migration[6.1]
  def up
    create_table :organizations do |t|
      t.string :name, unique: true, null: false
      t.string :full_name, index: true
      t.string :inn, limit: 10
      t.string :kpp, limit: 9

      t.timestamps
    end
    add_index :organizations, [:inn, :kpp], unique: true
  end

  def down
    drop_table :organizations
  end
end
