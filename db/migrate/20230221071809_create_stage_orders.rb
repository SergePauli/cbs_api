# заказы этапов 
class CreateStageOrders < ActiveRecord::Migration[6.1]
  def up
    create_table :stage_orders do |t|
      t.references :order, foreign_key: true, comment: "заказ" 
      t.references :stage, foreign_key: true, comment: "этап"
      t.references :isecurity_tool, null: false, foreign_key: true, comment: "СЗИ, товар"      
      t.integer :severity, comment: "критичность"
      t.float :price_cost, precision: 10, scale: 2, comment: "цена за единицу"      
      t.float :amount, comment: "колличество"
      t.float :cost, precision: 10, scale: 2, comment: "стоимость"      
      t.string :description, comment: "примечание"
      t.integer :priority, index: true, null: false, default: 0, comment: "порядок в списке"      
      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"
      t.timestamps
    end
  end

  def down
    drop_table :stage_orders
  end
end
