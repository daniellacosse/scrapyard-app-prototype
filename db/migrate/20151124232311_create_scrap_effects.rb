class CreateScrapEffects < ActiveRecord::Migration
  def change
    create_table :scrap_effects do |t|

      t.timestamps null: false
    end
  end
end