class CreatePartTargets < ActiveRecord::Migration
  def change
    create_table :weapon_targets do |t|

      t.timestamps null: false
    end
  end
end
