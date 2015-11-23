class CreateBlueprintRequirements < ActiveRecord::Migration
  def change
    create_table :blueprint_requirements do |t|

      t.timestamps null: false
    end
  end
end
