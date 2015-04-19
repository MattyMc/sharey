class CreateUnregisteredUsers < ActiveRecord::Migration
  def change
    create_table :unregistered_users do |t|
      t.string :email

      t.timestamps null: false
    end
  end
end
