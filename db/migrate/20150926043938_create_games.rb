class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :guid
      t.boolean :has_started, default: false

      t.timestamps null: false
    end
  end
end
