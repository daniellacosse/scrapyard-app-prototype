class CreateEffects < ActiveRecord::Migration
  def change
    create_table :effects do |t|
      t.string :description
      t.integer :magnitude

      t.timestamps null: false
    end
  end
end
