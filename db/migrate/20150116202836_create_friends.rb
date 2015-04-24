class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.belongs_to :user, index: true
      t.belongs_to :receiving_user, null: false
      t.string :receiving_user_type, null: false
      t.string :tag
      t.boolean :confirmed, default: false
      t.integer :group_id, default: nil

      t.timestamps null: false
    end
    add_foreign_key :friends, :users
    add_index :friends, [:user_id, :receiving_user_id, :receiving_user_type], unique: true, name:'by_receiving_user'
  end
end
