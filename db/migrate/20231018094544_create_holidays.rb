class CreateHolidays < ActiveRecord::Migration[6.1]
  def up
    create_table :holidays do |t|
      t.date :begin_at, index: true
      t.date :end_at
      t.string :name
      t.boolean :work

      t.timestamps
    end
  end

  def down
    drop_table :holidays
  end
end
