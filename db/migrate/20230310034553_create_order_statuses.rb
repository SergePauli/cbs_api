class CreateOrderStatuses < ActiveRecord::Migration[6.1]
  def up
    create_table :order_statuses do |t|
      t.string :name
      t.string :description
      t.integer :order
      t.timestamps
    end
  end

  def down
    drop_table :order_statuses
  end
end
