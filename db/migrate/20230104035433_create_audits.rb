# Аудит изменений
class CreateAudits < ActiveRecord::Migration[6.1]
  def up
    create_table :audits do |t|
      t.references :auditable, polymorphic: true, index: true, comment: "объект (место изменений)"
      t.integer :action, limit: 1, index: true, null: false, comment: "вид изменений"
      t.string :auditable_field, comment: "что изменили"
      t.string :detail, comment: "пояснение"
      t.string :before, comment: "данные до изменения"
      t.string :after, comment: "данные после изменения"
      t.belongs_to :user, index: true, comment: "ссылка на пользователя (кто изменил)"
      t.belongs_to :person, comment: "персональные данные пользователя, на момент комментирования"
      t.timestamps
    end
  end

  def down
    drop_table :audits
  end
end
