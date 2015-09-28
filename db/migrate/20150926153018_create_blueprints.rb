class CreateBlueprints < ActiveRecord::Migration
  def change
    create_table :blueprints do |t|
      t.string :requirement_1
      t.string :requirement_1_raw_value

      t.string :requirement_2
      t.string :requirement_2_raw_value

      t.string :requirement_3
      t.string :requirement_3_raw_value

      t.string :requirement_4
      t.string :requirement_4_raw_value

      t.string :requirement_5
      t.string :requirement_5_raw_value

      t.timestamps null: false
    end
  end
end
