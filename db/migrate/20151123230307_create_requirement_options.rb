class CreateRequirementOptions < ActiveRecord::Migration
  def change
    create_table :requirement_options do |t|

      t.timestamps null: false
    end
  end
end
