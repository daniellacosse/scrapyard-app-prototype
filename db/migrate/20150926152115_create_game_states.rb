class CreateGameStates < ActiveRecord::Migration
  def change
    create_table :game_states do |t|
      t.integer :player_id
      t.integer :player_number
      t.integer :game_id
      t.integer :raw, default: 0
      t.boolean :is_ready
      t.boolean :is_my_turn

      t.timestamps null: false
    end
  end
end
