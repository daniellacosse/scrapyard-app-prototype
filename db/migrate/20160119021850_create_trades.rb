class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.boolean :is_agreed, default: false

      t.integer :game_state_id
      t.integer :proposing_player_state_id

      t.integer :raw_cost
      t.integer :proposing_player_raw_cost

      t.integer :scrap_hold_cost
      t.integer :proposing_player_scrap_hold_cost

      t.integer :blueprint_hold_cost
      t.integer :proposing_player_blueprint_hold_cost

      t.integer :module_hold_cost
      t.integer :proposing_player_module_hold_cost

      t.timestamps null: false
    end
  end
end
