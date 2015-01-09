class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :low_case_name, null: false, unique: true
    end
  end
end
