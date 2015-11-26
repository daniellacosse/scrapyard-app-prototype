class CreateScrapClasses < ActiveRecord::Migration
  def change
    create_table :scrap_classes do |t|
      t.integer :scrap_id
      t.integer :class_type_id

      t.timestamps null: false
    end
  end
end
