class CreateClassTypes < ActiveRecord::Migration
  def change
    create_table :class_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
