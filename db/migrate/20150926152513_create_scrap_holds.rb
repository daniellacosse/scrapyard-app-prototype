class CreateScrapHolds < ActiveRecord::Migration
  def change
    create_table :scrap_holds do |t|
      t.integer :scrap_id
      t.integer :game_state_id

      t.timestamps null: false
    end
  end
end
