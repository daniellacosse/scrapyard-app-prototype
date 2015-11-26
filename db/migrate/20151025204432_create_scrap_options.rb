class CreateScrapOptions < ActiveRecord::Migration
  def change
    create_table :scrap_options do |t|
      t.integer :count, default: 1
      t.integer :scrap_id
      t.integer :option_id

      t.timestamps null: false
    end
  end
end
