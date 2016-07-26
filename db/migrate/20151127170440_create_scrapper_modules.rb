class CreateScrapperModules < ActiveRecord::Migration
  def change
    create_table :scrapper_modules do |t|
      t.integer :blueprint_id

      t.integer :armor
      t.string :damage_type
      t.integer :damage
      t.integer :mobility
      t.string :name
      t.integer :range
      t.integer :resilience
      t.integer :spread
      t.string :text
      t.string :module_class
      t.integer :weight

      t.timestamps null: false
    end
  end
end
