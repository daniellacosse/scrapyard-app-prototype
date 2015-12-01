class CreateModuleHolds < ActiveRecord::Migration
  def change
    create_table :module_holds do |t|
      t.integer :scrapper_module_id

      t.references :holdable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
