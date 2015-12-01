class CreateScrapHolds < ActiveRecord::Migration
  def change
    create_table :scrap_holds do |t|
      t.integer :scrap_id
      
      t.references :holdable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
