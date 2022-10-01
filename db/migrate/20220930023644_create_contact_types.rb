class CreateContactTypes < ActiveRecord::Migration[6.1]
  def up
    create_table :contact_types do |t|
      t.string :name
      t.string :icon_url
      t.string :comment

      t.timestamps
    end
  end

  def down
    drop_table :contact_types
  end
end
