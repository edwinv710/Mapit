class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :name
      t.string :width
      t.string :height
      t.integer :container_width
      t.integer :container_height
      t.integer :tile_width
      t.integer :tile_height
      t.integer :tileset_id
      t.string :map_source

      t.timestamps
    end
  end
end
