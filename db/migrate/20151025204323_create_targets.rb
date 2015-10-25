class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.string :name, unique: true

      t.timestamps null: false
    end
  end
end
