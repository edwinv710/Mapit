require 'test_helper'
require 'layer'

class MapTest < ActiveSupport::TestCase
   
   def get_sample_map
   	Map.create(:container_height => 480, :container_width => 480, :height => 16, 
   		:name => "Map1", :tile_height => 32, :tile_width => 32, :width => 16, 
   		:map_src => "map2.txt")
   end 

   def test_assert_tag
    boolean = get_sample_map().assert_tag("tileset", "<tileset>")
    boolean = boolean && get_sample_map().assert_tag("map", "<map(23,23)>")
    boolean = boolean && (not get_sample_map().assert_tag("mappy", "<map>"))
    boolean = boolean && (not get_sample_map().assert_tag("tile", "<tiley()>"))
    assert boolean
   end

   def test_extract_tag
    Rails::logger.debug "======Tag: #{get_sample_map().extract_tag("map", "<map(map1, 800, 600, 25, 25, 32, 32)>")}"
    boolean = (get_sample_map().extract_tag("map", "<map('tileset 1', 32, 32)>") == ["'tileset1'", '32', '32'])
    boolean = boolean && (get_sample_map().extract_tag("tileset", "<tileset('mappy', 320, 240)>") == ["'mappy'", '320', '240'])
    boolean = boolean && (not (get_sample_map().extract_tag("tileset", "<tileset('mappy', 32, 32)>") == ["'tileset1'", '32', '32']))
    boolean = boolean && (not (get_sample_map().extract_tag("tileset", "<tileset('tileset 1', 3, 32)>") ==  ["'tileset1'", '32', '32']))
    
    assert boolean
   end

   def test_extract_body
    body = ['<tileset>','tileset1.bmp','tileset2.bmp','</tileset>']
    items = get_sample_map().extract_body(body, "tileset")
    #Rails::logger.debug "Items #{items}"
    assert get_sample_map().extract_body(body, 'tileset') == ['tileset1.bmp', 'tileset2.bmp']
   end

   def test_import_tileset
    boolean = false
    body = ['<tileset>','tileset1.bmp','tileset2.bmp','</tileset>']
    tilesets = get_sample_map().import_tileset(body)
    boolean = (tilesets.length > 1)
    tilesets.each do |tileset|
      boolean = boolean && (tileset.instance_of? Tileset)
    end
    assert boolean
   end
   
   def test_map_validation

   end


   def test_map_createLayers
   	map1 = get_sample_map()
   	layers_object_array = map1.createLayers()
    isLayer = (layers_object_array.length > 0)

   	layers_object_array.each do |layer|
   		isLayer = (isLayer and (layer.instance_of? Layer))
   	end

   	assert isLayer
   end

end
