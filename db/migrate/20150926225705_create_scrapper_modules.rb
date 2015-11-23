class CreateScrapperModules < ActiveRecord::Migration
  def change
    create_table :scrapper_modules do |t|
      t.string :name
      t.string :mod_type
      t.string :armor
      t.string :res
      t.string :weight
      t.string :gives_digging
      t.string :gives_flying
      t.string :weapon_type
      t.string :weapon_dmg
      t.string :weapon_acc

      t.timestamps null: false
    end
  end
end
