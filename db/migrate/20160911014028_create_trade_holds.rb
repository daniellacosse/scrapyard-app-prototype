class CreateTradeHolds < ActiveRecord::Migration
  def change
    create_table :trade_holds do |t|
      t.integer :trade_id
      t.integer :scrap_hold_id

      t.timestamps null: false
    end
  end
end
