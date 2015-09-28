class CreateScrapHolds < ActiveRecord::Migration
  def change
    create_table :scrap_holds do |t|

      t.timestamps null: false
    end
  end
end
