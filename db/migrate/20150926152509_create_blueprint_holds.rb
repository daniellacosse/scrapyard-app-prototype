class CreateBlueprintHolds < ActiveRecord::Migration
  def change
    create_table :blueprint_holds do |t|
      t.integer :blueprint_id
      t.integer :game_state_id
      t.integer :game_id

      t.timestamps null: false
    end
  end
end
