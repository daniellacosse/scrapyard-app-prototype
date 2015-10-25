class CreateScraps < ActiveRecord::Migration
  def change
    create_table :scraps do |t|
      t.string :name
      t.string :scrap_type
      t.string :raw_value
      t.string :event_effect
      t.boolean :has_event

      t.timestamps null: false
    end
  end
end
