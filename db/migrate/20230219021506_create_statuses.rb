class CreateStatuses < ActiveRecord::Migration[6.1]
  def up
    create_table :statuses do |t|
      t.string :name
      t.timestamps
    end
  end

  def down
    drop_table :statuses
  end
end
