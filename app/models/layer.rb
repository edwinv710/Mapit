class Layer < ActiveRecord::Base
  attr_accessible :array, :background_color, :horizontal_speed, :image, :is_fill_layer, :is_y_repeat, :is_scrolling, :is_sequence_layer, :is_static, :is_tile_layer, :is_tile_scroll, :is_x_repeat, :is_x_stretch, :is_y_stretch, :map_id, :opacity, :sequence_array, :tileset_id, :vertical_speed

  belongs_to :map
  belongs_to :tileset

  validates :map_id, presence: true

  # Runs before the layer is saved
  def init
    check_sequence()
  end
  
  # Checks if the array contains sequence tiles. If it does it creates a sequence
  	# array to be used by the javascript.
  def check_sequence
    is_sequence = false

    unless array.nil?
      reg_array = Layer.to_array(self.array, true) 
    else
      reg_array = nil
    end

    unless reg_array.nil?
      height = reg_array.size
      width = reg_array[0].size
      seq_string = ""
      s_array = Array.new
      
      (0...height).each do |i|
        (0...width).each do |j|
          function = Map.extract_function(reg_array[i][j])
          values = Map.extract_function_body(function,reg_array[i][j])
          if values.length > 0 
            is_sequence = true
            reg_array[i][j] = 0
            string = "#{function},#{i},#{j}"
            values.each do |val|
              string = "#{string},#{val}"
            end
            s_array.push(string)
          end

        end
      end

      if is_sequence
        self.sequence_array = s_array.join('-')
        self.array = Layer.to_string(reg_array)
      end
    end
  end

 # Converts the string representation of the layer to an array (instance function version)
  def to_array
    if array != nil
    	return_array = Array.new(25)
    	line_array = array.split("-")
    	
    	line_array.each do |line|
    		return_array.push(line.split(',').map { |x| x.to_i })
    	end
    	return return_array
    else
      return nil
    end
  end 

 # Converts an array to a string representation  (class function version)
  def self.to_string(sample_array)
    s1 = Array.new()
    s2 = Array.new()
    return_string = ""

    (0...sample_array.length).each do |i|
      (0...sample_array[i].length).each do |j|
        if sample_array[i][j].instance_of? Array
          s1.push((sample_array[i][j]).join('.'))
        else
          s1.push(sample_array[i][j])
        end
      end
      s2.push(s1.join(','))
      s1 = Array.new()
    end
    return_string = s2.join('-')
  end
  
   # Converts the string representation of the layer to an array (class function version)
  def self.to_array(sample_array, multi_level = false)
    return_array = Array.new()
    line_array = sample_array.split("-")
  
    line_array.each do |line|
      values = line.split(',')
      unless multi_level
        (0...values.length).each do |i|
          elements = values[i].split('.')
          if elements.length == 1
            values[i] = elements[0]
          else
            values[i] = elements
          end
        end
      end
      return_array.push(values)
    end

    return return_array
  end


  #def layer_array=(var)
  #  @layer_array = var
  #end
end
