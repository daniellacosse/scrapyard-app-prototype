class CreateScrapEffects < ActiveRecord::Migration
  def change
    create_table :scrap_effects do |t|
      t.integer :scrap_id
      t.integer :effect_id

      t.timestamps null: false
    end
  end
end
