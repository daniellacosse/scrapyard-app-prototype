class CreateContestants < ActiveRecord::Migration
  def change
    create_table :contestants do |t|
      t.string :name
      t.integer :eng_lvl
      t.integer :body_lvl
      t.integer :pilot_lvl
      t.integer :chassis_lvl

      t.timestamps null: false
    end
  end
end
