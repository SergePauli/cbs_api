# комменты
class CreateComments < ActiveRecord::Migration[6.1]
  def up
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, index: true, comment: "что комментируем"
      t.string :content, null: false, comment: "содержание комментария"
      t.belongs_to :profile, index: true, comment: "профиль пользователя с должностью и отделом"
      t.belongs_to :person, comment: "данные пользователя, на момент комментирования"
      t.timestamps # метки создания и редактирования коммента
    end
  end

  def down
    drop_table :comments
  end
end
