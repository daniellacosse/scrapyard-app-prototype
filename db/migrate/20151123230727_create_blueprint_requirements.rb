class CreateBlueprintRequirements < ActiveRecord::Migration
  def change
    create_table :blueprint_requirements do |t|
      t.integer :blueprint_id
      t.integer :requirement_id

      t.timestamps null: false
    end
  end
end
