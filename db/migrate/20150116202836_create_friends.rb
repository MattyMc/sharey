class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.belongs_to :user, index: true
      t.integer :receiving_user_id, null: false
      t.string :downcase_tag
      t.string :tag
      t.boolean :confirmed, default: false
      t.integer :group_id, default: nil

      t.timestamps null: false
    end
    add_foreign_key :friends, :users
    add_index :friends, [:user_id, :receiving_user_id], unique: true
  end
end
