class Map < ActiveRecord::Base
  attr_accessible :container_height, :container_width, :height, :map_source, :name, :tile_height, :tile_width, :tileset_id, :width

  has_many :layers

  validates :container_width, presence: true
  validates :container_height, presence: true
  validates :width, presence: true
  validates :height, presence: true
  validates :name, presence: true
  validates :tile_width, presence: true
  validates :tile_height, presence: true
  validates :map_source, presence: true


  # Extracts the functions name from a string
  # Format: "function(parameter*)"
  # Returns: "function"
  def self.extract_function(string)
    string.gsub(/\(([^\)]+)\)/, "")
  end
  
  # Returns true if the tags is includes in the string 
  # Format: tag => "tag_name", string => "<tag_name>" | "<tag_name(parameters*)"
  # Return : True or False
  def assert_tag(tag, string)
    complete_tag = "<#{tag}>"
    partial_tag = "<#{tag}("
    (string.include? complete_tag) || (string.include? partial_tag)
  end

  # Extracts the paramters from the tag
  # Format: tag => "tag_name", string => "<tag_name>" | "<tag_name(parameters*)"
  # Return: array => [paramters*] || array => []
  def self.extract_tag(tag, string)
    dup = string 
    tag = "<#{tag}"
    dup = dup.gsub(/[()>]|(#{tag})|\s+(?=((\\[\\"]|[^\\"])*"(\\[\\"]|[^\\"])*")*(\\[\\"]|[^\\"])*$)/, "")
    dup.split(',')
  end


  def self.extract_function_body(tag, string)
    string = string.gsub(/[()>]|(#{tag})|\s+(?=((\\[\\"]|[^\\"])*"(\\[\\"]|[^\\"])*")*(\\[\\"]|[^\\"])*$)/, "")
    string.split('.')
  end
  
  # Extracts the lines between an opening and closing tag
  # Format: array => ["<tag>"]["lines"]*[</tag>]
  # Return: ["lines"]*
  def extract_body(array, tag)
    index = 0
    height = array.length
    r_array = Array.new
    opening_tag = "<#{tag}>"
    closing_tag = "</#{tag}>"
    return_array = Array.new
    while index < height
      current_line = array[index].strip
      if assert_tag(tag, current_line)
        index = index + 1
        while(array[index].strip != closing_tag)
          r_array.push(array[index].strip)
          index = index + 1
        end
        index = height
      end
    end
    r_array
  end

  # Creates tileset objects based on the on the lines between the tileset tags
  # Format: array => ["<tileset>"]["tileset_source"]*["</tileset>"] 
  # Return: ["tileset_source"]*
  def import_tileset(array)
    index = 0
    tileset_array = Array.new
    @tilesets = Array.new
    while index < array.length
      current_line = array[index].strip
      if assert_tag("tileset", current_line)
        tileset_values = extract_body(array[index...array.length],"tileset")
        index = array.length
      end
      index = index.next
    end
    tileset_values.each do |tileset|
      tileset = Tileset.where(source: tileset).first_or_create!
      @tilesets.push(tileset)
      tileset_array.push(tileset)
    end
    tileset_array
  end
  
  def import_tag(tag, array)
    index = 0
    values = Array.new

    while index < array.length
      current_line = array[index].strip
      if assert_tag(tag, current_line)
        values = Map.extract_tag(tag, current_line)
        index = array.length
      end
      index = index.next
    end
    values
  end

  def import_background(array)
    values = import_tag('background', array)
    self.background_color = values[0]
  end


  # Imports the map attributes from the map tag eg tile_width tile_height etc.
  # Format array => [<map(640, 480, 20, 15, 32, 32)>][lines]*[</map>]
  def import_attributes(array)
    index = 0
    map_values = Array.new 

    while index < array.length
      current_line = array[index].strip
      #puts current_line
      if assert_tag("map", current_line)
        map_values = Map.extract_tag("map", current_line)
        index = array.length
      end
      index = index.next
    end

    if map_values.length >= 7
      self.name = map_values[0]
      self.container_width = map_values[1]
      self.container_height = map_values[2]
      self.width = map_values[3]
      self.height = map_values[4]
      self.tile_width = map_values[5]
      self.tile_height = map_values[6]
    end
  end
  
  # Imports the map file and creates all the layers based on the information provided in the 
  	# map file. 
  def import(root_path = Rails.root, folders = "/public/")
    map_file = File.open("#{root_path}#{folders}#{map_source}", "r")
    map_array = map_file.readlines
    map_height = map_array.length
    layers_array = Array.new
    index = 0

    import_attributes(map_array)
    import_tileset(map_array)

    while index < map_height
      current_line = map_array[index].to_s.strip 
      if assert_tag("layer", current_line)
        default_values = [0,0,0,0,0,0]
        values = Map.extract_tag("layer", current_line)
        (0...default_values.length).each do |i|
          unless values[i].nil?
            default_values[i] = values[i].to_i
          end
        end
        current_layer = extract_body(map_array[index...map_height],"layer")
        layer_string = ""
        current_layer.each do |line|
          layer_string = layer_string + line + "-"
        end
        is_scrolling = ((default_values[3] != 0 || default_values[4] != 0))
        new_layer = Layer.create(array: layer_string.chop, is_tile_layer: true, tileset_id: @tilesets[default_values[0]].id, is_static: (default_values[2] == 1), horizontal_speed: default_values[3], vertical_speed: default_values[4], is_tile_scroll: default_values[5], opacity: default_values[1], is_scrolling: is_scrolling )
        layers_array.push(new_layer)
      end

      if assert_tag("fill", current_line)
        values = Map.extract_tag("fill", current_line)
        new_layer = Layer.create(background_color: values[0], is_fill_layer: true, opacity: values[1].to_f)
        layers_array.push(new_layer)
      end

      if assert_tag("background_image", current_line)
        values = Map.extract_tag("background_image", current_line)
        new_layer = Layer.create(image: values[0], is_x_repeat: values[1], is_y_repeat: values[2], is_x_stretch: values[3], is_y_stretch: values[4], is_static: values[5])
        layers_array.push(new_layer)
      end
      index = index.next
    end
    return layers_array
  end
  
  # Creates a layer array with all the layers from the map source
  def createLayers()
    @layers_array = import()    
  end

  # Saves the layers once the map is created. Map id cannot be saves before its created
  def save_layers()
    @layers_array.each do |layer|
      layer.map_id = self.id
      layer.init
      layer.save!
    end
  end

  #Deletes all the layers and recreates the layers 
  def updateLayers()
    layers.each do |layer|
      layer.destroy
    end
    #tilesets.each do |tileset|
    #  tilesets.delete(tileset)
    #end
    createLayers()
  end

end
