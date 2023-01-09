class CreatePeople < ActiveRecord::Migration[6.1]
  def change
    create_table :people do |t|
      t.string :inn, limit: 12
      t.timestamps
    end
  end
end
