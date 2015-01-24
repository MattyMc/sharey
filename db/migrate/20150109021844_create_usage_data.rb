class CreateUsageData < ActiveRecord::Migration
  def change
    create_table :usage_data do |t|
      t.belongs_to :item, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.boolean :viewed, default: true
      t.boolean :deleted, default: false
      t.integer :click_count, default: 0
      t.boolean :shared, default: false

      t.timestamps null: false
    end
    add_foreign_key :usage_data, :items
    add_foreign_key :usage_data, :users
  end
end
