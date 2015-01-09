class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :downcase_name, null: false, unique: true
      t.belongs_to :user, index: true, null: false
    end
    add_foreign_key :categories, :users
    add_index :categories, [:user_id, :downcase_name], unique: true
  end
end
