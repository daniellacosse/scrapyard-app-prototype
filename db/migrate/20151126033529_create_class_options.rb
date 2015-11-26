class CreateClassOptions < ActiveRecord::Migration
  def change
    create_table :class_options do |t|
      t.integer :class_type_id
      t.integer :option_id
      t.integer :count, default: 1

      t.timestamps null: false
    end
  end
end
