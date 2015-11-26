class CreateWeaponTargets < ActiveRecord::Migration
  def change
    create_table :weapon_targets do |t|
      t.integer :scrapper_module_id
      t.integer :target_id

      t.timestamps null: false
    end
  end
end
