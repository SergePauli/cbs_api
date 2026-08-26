# Ответственные лица за исполнение контракта на стороне контрагента
class CreateContractResponsibles < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_responsibles do |t|
      t.references :contract, null: false, foreign_key: true, comment: "контракт"
      t.references :employee, null: false, foreign_key: true, comment: "ответственное лицо"
      t.integer :priority, index: true, null: false, default: 0, comment: "порядок в списке"
      t.boolean :used, null: false, default: true, comment: "признак использования"
      t.uuid :list_key, null: false, comment: "служебный ключ списка, для логгирования"

      t.timestamps
    end

    add_index :contract_responsibles,
              [:contract_id, :employee_id],
              unique: true
  end
end
