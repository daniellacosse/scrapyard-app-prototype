class CreateScraps < ActiveRecord::Migration
  def change
    create_table :scraps do |t|
      t.string :name
      t.string :value

      t.timestamps null: false
    end
  end
end
