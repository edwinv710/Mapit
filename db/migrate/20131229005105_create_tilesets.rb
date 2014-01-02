class CreateTilesets < ActiveRecord::Migration
  def change
    create_table :tilesets do |t|
      t.string :source

      t.timestamps
    end
  end
end
