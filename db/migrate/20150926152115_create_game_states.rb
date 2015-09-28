class CreateGameStates < ActiveRecord::Migration
  def change
    create_table :game_states do |t|
      t.integer :player_id
      t.integer :game_id
      t.integer :raw
      t.boolean :is_my_turn

      t.references :holdable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
