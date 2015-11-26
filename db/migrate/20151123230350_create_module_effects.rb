class CreateModuleEffects < ActiveRecord::Migration
  def change
    create_table :module_effects do |t|
      t.integer :scrapper_module_id
      t.integer :effect_id

      t.timestamps null: false
    end
  end
end
