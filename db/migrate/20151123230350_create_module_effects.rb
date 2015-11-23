class CreateModuleEffects < ActiveRecord::Migration
  def change
    create_table :module_effects do |t|

      t.timestamps null: false
    end
  end
end
