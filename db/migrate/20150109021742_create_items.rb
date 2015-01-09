class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.belongs_to :document, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.integer :from_user_id, index: true, default: nil
      t.belongs_to :category, index: true, default: nil
      t.string :description

      t.timestamps null: false
    end
    # TODO: Add from_user_id as a foreign_key here?
    add_foreign_key :items, :documents
    add_foreign_key :items, :users
    add_foreign_key :items, :categories
  end
end
