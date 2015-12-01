class CreateBlueprintHolds < ActiveRecord::Migration
  def change
    create_table :blueprint_holds do |t|
      t.integer :blueprint_id
      
      t.references :holdable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
