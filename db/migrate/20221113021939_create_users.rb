class CreateUsers < ActiveRecord::Migration[6.1]
  def up
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.references :person, null: false, foreign_key: true
      t.string :role, null: false, default: "user"
      t.datetime :last_login
      t.timestamps
    end
    add_index :users, :name, unique: true
  end

  def down
    drop_table :users
  end
end
