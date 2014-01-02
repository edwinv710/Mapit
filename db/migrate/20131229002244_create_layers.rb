class CreateLayers < ActiveRecord::Migration
  def change
    create_table :layers do |t|
      t.text :array
      t.integer :map_id
      t.integer :tileset_id
      t.boolean :is_static, :default => false
      t.string :background_color
      t.integer :vertical_speed, :default => 0
      t.integer :horizontal_speed, :default => 0
      t.boolean :is_tile_scroll, :default => false
      t.decimal :opacity, :precision => 1, :scale => 1
      t.boolean :is_tile_layer, :default => false
      t.boolean :is_fill_layer, :default => false
      t.boolean :is_scrolling, :default => false
      t.boolean :is_sequence_layer, :default => false
      t.text :sequence_array
      t.string :image
      t.boolean :is_x_stretch, :default => false
      t.boolean :is_y_stretch, :default => false
      t.boolean :is_x_repeat, :default => false
      t.boolean :is_repeat, :default => false

      t.timestamps
    end
  end
end
