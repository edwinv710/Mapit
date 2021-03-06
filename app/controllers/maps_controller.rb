require 'yaml'

class MapsController < ApplicationController
  secure = YAML::load_file("#{Rails.root}/config/application.yml")
  http_basic_authenticate_with :name => secure['access']['username'], :password => secure['access']['password'], :except => [:show]

  # GET /maps
  # GET /maps.json
  def index

    @maps = Map.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maps }
    end
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
    @tilesets = Array.new
    @map = Map.find(params[:id])
    @layers = @map.layers
    @layers.each do |layer|
     tileset_id = layer.tileset_id
     unless tileset_id.nil?
      @tilesets.push(Tileset.find(tileset_id))
     end
    end
    @tilesets = @tilesets.uniq

    
    @maps_array = Map.all.map { |map| [map.name, map.id] }

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @map }
    end
  end

  # GET /maps/new
  # GET /maps/new.json
  def new
    @map = Map.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @map }
    end
  end

  # GET /maps/1/edit
  def edit
    @map = Map.find(params[:id])

  end

  # POST /maps
  # POST /maps.json
  def create
    @map = Map.new(params[:map])
    @map.createLayers()

    respond_to do |format|
      if @map.save
        @map.save_layers()
        format.html { redirect_to @map, notice: 'Map was successfully created.' }
        format.json { render json: @map, status: :created, location: @map }
      else
        format.html { render action: "new" }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /maps/1
  # PUT /maps/1.json
  def update
    @map = Map.find(params[:id])

    respond_to do |format|
      if @map.update_attributes(params[:map])
        @map.updateLayers()
        format.html { redirect_to @map, notice: 'Map was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.json
  def destroy
    @map = Map.find(params[:id])
    @map.destroy

    respond_to do |format|
      format.html { redirect_to maps_url }
      format.json { head :no_content }
    end
  end
  
end
