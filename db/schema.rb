# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131230054623) do

  create_table "layers", :force => true do |t|
    t.text     "array"
    t.integer  "map_id"
    t.integer  "tileset_id"
    t.boolean  "is_static",                                       :default => false
    t.string   "background_color"
    t.integer  "vertical_speed",                                  :default => 0
    t.integer  "horizontal_speed",                                :default => 0
    t.boolean  "is_tile_scroll",                                  :default => false
    t.decimal  "opacity",           :precision => 1, :scale => 1
    t.boolean  "is_tile_layer",                                   :default => false
    t.boolean  "is_fill_layer",                                   :default => false
    t.boolean  "is_scrolling",                                    :default => false
    t.boolean  "is_sequence_layer",                               :default => false
    t.text     "sequence_array"
    t.string   "image"
    t.boolean  "is_x_stretch",                                    :default => false
    t.boolean  "is_y_stretch",                                    :default => false
    t.boolean  "is_x_repeat",                                     :default => false
    t.boolean  "is_y_repeat",                                     :default => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  create_table "maps", :force => true do |t|
    t.string   "name"
    t.string   "width"
    t.string   "height"
    t.integer  "container_width"
    t.integer  "container_height"
    t.integer  "tile_width"
    t.integer  "tile_height"
    t.integer  "tileset_id"
    t.string   "map_source"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "tilesets", :force => true do |t|
    t.string   "source"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
