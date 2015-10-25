class CreateBlueprints < ActiveRecord::Migration
  def change
    create_table :blueprints do |t|
      t.string :name
      t.string :rank

      t.timestamps null: false
    end
  end
end
