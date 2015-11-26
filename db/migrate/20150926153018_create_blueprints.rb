class CreateBlueprints < ActiveRecord::Migration
  def change
    create_table :blueprints do |t|
      t.string :rank
      t.integer :scrapper_module_id

      t.timestamps null: false
    end
  end
end
