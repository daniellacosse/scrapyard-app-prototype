class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :game_state_id
      t.string :text
      t.boolean :is_viewed, default: false

      t.timestamps null: false
    end
  end
end
