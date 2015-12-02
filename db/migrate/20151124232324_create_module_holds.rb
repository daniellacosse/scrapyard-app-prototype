class CreateModuleHolds < ActiveRecord::Migration
  def change
    create_table :module_holds do |t|
      t.integer :scrapper_module_id
      t.integer :game_state_id

      t.timestamps null: false
    end
  end
end
