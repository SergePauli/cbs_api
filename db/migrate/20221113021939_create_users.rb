class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.references :person, null: false, foreign_key: true
      t.string :role, null: false, default: "user"
      t.datetime :last_login
      t.timestamps
    end
  end
end
