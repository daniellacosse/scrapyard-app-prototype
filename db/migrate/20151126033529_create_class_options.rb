class CreateClassOptions < ActiveRecord::Migration
  def change
    create_table :class_options do |t|
      t.integer :count

      t.timestamps null: false
    end
  end
end
