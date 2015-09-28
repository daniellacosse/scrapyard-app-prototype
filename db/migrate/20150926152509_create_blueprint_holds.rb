class CreateBlueprintHolds < ActiveRecord::Migration
  def change
    create_table :blueprint_holds do |t|

      t.timestamps null: false
    end
  end
end
