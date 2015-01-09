class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :url, unique: true, null: false
      t.string :title
      t.integer :originator_id, default: nil

      t.timestamps null: false
    end
  end
end
