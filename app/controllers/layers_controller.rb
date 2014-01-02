class LayersController < ApplicationController

	def index
	  @layers = Map.find(params[:map_id]).layers

	  @layers.each do |layer|
	  	if layer["array"] != nil
	  		layer["array"] = Layer.to_array(layer["array"])
	  	end
	  	if layer["sequence_array"] != nil
	  		layer["sequence_array"] = Layer.to_array(layer["sequence_array"])
	  	end
	  end
	  respond_to do |format|
      	#format.html # index.html.erb
      	format.json { render json: @layers }
      end
	end
end
