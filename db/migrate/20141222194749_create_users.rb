class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :image
      t.string :token
      t.string :refresh_token
      t.string :sharey_session_cookie
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_index :users, :uid, unique: true
    add_index :users, :email, unique: true
  end
end
