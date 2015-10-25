class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :name
      t.string :part_type
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
