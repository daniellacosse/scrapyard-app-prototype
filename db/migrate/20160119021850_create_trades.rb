class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.integer :game_id

      t.integer :solicitor_player_state_id
      t.integer :solicitor_raw_cost, default: 0

      t.integer :solicited_player_state_id
      t.integer :solicited_raw_cost, default: 0

      t.boolean :is_revised, default: false
      t.boolean :is_agreed, default: false

      t.timestamps null: false
    end
  end
end
