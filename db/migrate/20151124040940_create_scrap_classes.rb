class CreateScrapClasses < ActiveRecord::Migration
  def change
    create_table :scrap_classes do |t|

      t.timestamps null: false
    end
  end
end
