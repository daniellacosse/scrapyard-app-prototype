class CreateRequirementOptions < ActiveRecord::Migration
  def change
    create_table :requirement_options do |t|
      t.integer :requirement_id
      t.integer :option_id

      t.timestamps null: false
    end
  end
end
