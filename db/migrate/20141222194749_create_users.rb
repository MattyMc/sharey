class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, unique: true
      t.string :image_url
      t.string :uid, unique: true

      t.string :sharey_session_cookie

      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps null: false
    end
  end
end
