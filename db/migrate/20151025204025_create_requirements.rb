class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.integer :override_value

      t.timestamps null: false
    end
  end
end
