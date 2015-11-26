class CreateModuleHolds < ActiveRecord::Migration
  def change
    create_table :module_holds do |t|

      t.timestamps null: false
    end
  end
end
