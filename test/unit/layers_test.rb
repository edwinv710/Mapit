require 'test_helper'
require 'map'

class LayerTest < ActiveSupport::TestCase
  
  def get_sample_map
   	Map.create(:container_height => 480, :container_width => 480, :height => 16, 
   		:name => "Map1", :tile_height => 32, :tile_width => 32, :width => 16, 
   		:map_src => "map1.csv", :tileset_id => 1)
  end  

  def test_layer_to_array_is_array
  	Rails::logger.debug "============== Testing: test_layer_to_array ================"
   	is_array = true
   	map1 = get_sample_map()
   	layers_object_array = map1.createLayers([0,1])

   	layers_object_array.each do |lay|
   			Rails::logger.debug "#{lay.to_array()}"
   		is_array = is_array and (lay.to_array().instance_of? Array)
   	end
  	
  	assert is_array
  end
end
