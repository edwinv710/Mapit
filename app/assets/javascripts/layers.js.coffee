class @Layer
	constructor: (@map) ->
		@canvas = document.createElement('canvas')
		@canvas.className = "canvas"
		@canvas.width = @map.canvas_width
		@canvas.height = @map.canvas_height
		@canvas.tabIndex = "1"
		$('#canvas_container').append(@canvas)
		@context = @canvas.getContext("2d")
		@update = true

	set_display: (boolean) ->
		if boolean == true
			@active = true
			@canvas.style.visibility = "visible"
		else
			@active = false
			@canvas.style.visibility = "hidden"

	render: () ->

	display: () ->

class @FillLayer extends @Layer
	constructor: (@map, @color, @opacity) ->
		super(@map)
		@context.globalAlpha = 1 - @opacity
		@context.fillStyle = @color
		@context.fillRect(0, 0, @map.canvas_width, @map.canvas_height)


class @ImageLayer extends @Layer
	constructor: (@map, @image_src, @repeat_x, @repeat_y, @stretch_x, @stretch_y, @is_static) ->
		super(@map)
		@image = new Image()
		@x_one = 0
		@y_one = 0
		@load = false

		self = @
		self.set = @image.onload = ->
			self.set_load()
			console.log(self.image.src)
		@image.src = "/assets/"+@image_src


	set_load: () ->
		@load = true

	render: () ->
		unless @isStatic
			@width = @image.width
			@height = @image.height
			if @stretch_x
				@width = @canvas.width
			if @stretch_y
				@height = @canvas.height
			current_x = @map.starting_tile_x * @map.tile_width + @map.left_clip
			x_offset = (current_x + @width) % @width
			@x_one = (x_offset * -1)  
			current_y = @map.starting_tile_y * @map.tile_height + @map.top_clip
			y_offset = (current_y + @height) % @height
			@y_one =  (y_offset * -1)
			
	display: () ->
		if @load
			@canvas.getContext("2d").clearRect(0, 0, @canvas.width, @canvas.height)
			@canvas.getContext("2d").drawImage(@image, 0, 0, @image.width, @image.height, @x_one, @y_one, @width, @height)
			if @repeat_x
				repeat_x_count = 0
				remaining_width = repeat_x_count * @image.width
				while remaining_width < @canvas.width
					repeat_x_count = repeat_x_count + 1
					remaining_width = repeat_x_count * @image.width
					new_x = remaining_width + @x_one
					@canvas.getContext("2d").drawImage(@image, 0, 0, @image.width, @image.height, new_x, @y_one, @width, @height)
			if @repeat_y
				repeat_y_count = 0
				remaining_height = repeat_y_count * @image.height
				while remaining_height < @canvas.height
					repeat_y_count = repeat_y_count + 1
					remaining_height = repeat_y_count * @image.height
					new_y = remaining_height + @y_one
					@canvas.getContext("2d").drawImage(@image, 0, 0, @image.width, @image.height, @x_one, new_y, @width, @height)
			if @repeat_x and @repeat_y
				@canvas.getContext("2d").drawImage(@image, 0, 0, @image.width, @image.height, @x_two, @y_two, @width, @height)

class @TileLayer extends @Layer
	constructor: (@map, @tile_set, @array, @isStatic) ->
		super(@map)
		tileset_id = "#tileset_"+@tile_set
		@tileImage = document.querySelector(tileset_id)
		console.log(@tileImage.width)
		@opacity = 0
		@active = true
		@displayed = false
		for i in [0...@array.length]
			for j in [0...@array[i].length]
				array[i][j] = parseInt(array[i][j])

	set_opacity: (opacity) ->
		@opacity = parseInt(opacity)

	display_layer: () ->
		@context.globalAlpha = 1 - @opacity
		width = @map.tiled_displayed_width
		height = @map.tiled_displayed_height
		@canvas.getContext("2d").clearRect(0, 0, @canvas.width, @canvas.height)
		for i in [0...height]
			if (@map.starting_tile_y + i) < @array.length
				row = i + @map.starting_tile_y
				for j in [0...width]
					if (@map.starting_tile_x + j) < @array[row].length
						tile = @array[row][j + @map.starting_tile_x]
						if tile > 0
							tileset_x = (@map.tile_width * tile) % @tileImage.width #tileImage.width  get the x location of the tile
							tileset_y = (Math.floor((@map.tile_width * tile) / @tileImage.width )) * @map.tile_height # get y location of the tile
							canvas_x = j * (@map.tile_width * @map.scale) - @map.left_clip # The x location where the tile will be placed on canvas
							canvas_y = i * (@map.tile_height * @map.scale) - @map.top_clip# The y location where the tile will be placed on canvas
							@context.globalAlpha = 1 - @opacity
							@canvas.getContext("2d").drawImage(@tileImage, tileset_x, tileset_y, @map.tile_width, @map.tile_height, canvas_x, canvas_y, @map.tile_width * @map.scale, @map.tile_height * @map.scale)
					
	display: () ->
		if ((@isStatic == false || @displayed == false) && @active == true)
			if @update
				@displayed = true
				@display_layer()

class @TileScrollLayer extends @TileLayer
	constructor:(@map, @tileset, @array, @x_speed, @y_speed) ->
		super(@map, @tileset, @array, true)
		@speed = 60
		@displayed = false
		@display_width = @map.tiled_displayed_width+1
		@display_height = @map.tiled_displayed_height+1
		@offset_x = 0
		@offset_y = 0
		@context.globalAlpha = .7

	draw_scrolling_tile: (tile, block_x, block_y, horizontal_offset, vertical_offset) ->
		tileset_x = (@map.tile_width * tile) % @tileImage.width #tileImage.width  get the x location of the tile
		tileset_y = (Math.floor((@map.tile_width * tile) / @tileImage.width )) * @map.tile_height # get y location of the tile
		x_one = tileset_x
		y_one = tileset_y
		width_one = -1
		width_two = -1
		height_one = -1
		height_two = -1
		canvas_x_one = (block_x) * (@map.tile_width * @map.scale) - @map.left_clip# The x location where the tile will be placed on canvas
		canvas_y_one = (block_y) * (@map.tile_height * @map.scale) - @map.top_clip
		canvas_x_two = canvas_x_one
		canvas_y_two = canvas_y_one

		# The y location where the tile will be placed on canvas
		
		if horizontal_offset != 0					
			if horizontal_offset > 0
				width_one  = horizontal_offset
				width_two  = @map.tile_width - horizontal_offset
			else
				width_one = @map.tile_width + horizontal_offset
				width_two = horizontal_offset * -1
			height_one = @map.tile_height
			height_two = @map.tile_height
			x_one = tileset_x + width_two
			canvas_x_two = (block_x) * (@map.tile_width * @map.scale) + width_one - @map.left_clip

		
		if vertical_offset != 0
			if vertical_offset > 0
				height_one  = vertical_offset
				height_two  = @map.tile_height - vertical_offset
			else
				height_one = @map.tile_height + vertical_offset 
				height_two = vertical_offset * -1
			if width_one == - 1 && width_two == -1
					width_one = @map.tile_width
					width_two = @map.tile_width	
			y_one = tileset_y + height_two
			canvas_y_two = (block_y * @map.tile_height * @map.scale) + height_one - @map.top_clip

		
		
		if (width_one + width_two + height_one + height_two ) != -4
			#console.log(width_one+","+height_one+" --- "+width_two+","+height_two)
			@canvas.getContext("2d").drawImage(@tileImage, x_one, y_one, width_one, height_one, canvas_x_one, canvas_y_one, width_one * @map.scale, height_one* @map.scale)			
			@canvas.getContext("2d").drawImage(@tileImage, tileset_x, tileset_y, width_two, height_two, canvas_x_two, canvas_y_two, width_two * @map.scale, height_two * @map.scale)

	render: () ->
		#canvas.getContext("2d").clearRect(0, 0, canvas.width, canvas.height)
		@starting_tile_x = @map.starting_tile_x
		@starting_tile_y = @map.starting_tile_y
		@offset_x = @offset_x + @x_speed
		@offset_y = @offset_y + @y_speed
		if @offset_x > @map.tile_width
			@offset_x = @offset_x - @map.tile_width
		if @offset_x < (@map.tile_width * -1)
			@offset_x = @offset_x + @map.tile_width
		if @offset_y > @map.tile_height
			@offset_y = @offset_y - @map.tile_height
		if @offset_y < (@map.tile_height * -1)
			@offset_y = @offset_y + @map.tile_height

	display:() ->
		@canvas.getContext("2d").clearRect(0, 0, @canvas.width, @canvas.height)
		width = @map.tiled_displayed_width
		height = @map.tiled_displayed_height

		for i in [0...height]
			if (@map.starting_tile_y + i < @array.length)
				row = i + @map.starting_tile_y
				for j in [0...width]
					if(@map.starting_tile_x + j) < @array[row].length
						tile = @array[row][@map.starting_tile_x+j]
						if tile > 0
							@draw_scrolling_tile(tile, j, i, @offset_x, @offset_y)


class @ScrollingTileLayer extends @TileLayer
	constructor:(@map, @tileset, @array, @horizontal_speed, @vertical_speed) ->
		super(@map, @tileset, @array, true)
		@speed = 60
		@starting_tile_x = 0
		@starting_tile_y = 0
		@left_clip = 0
		@top_clip = 0
		@displayed = false
		@context.globalAlpha = .8

	display:  ->
		@canvas.getContext("2d").clearRect(0, 0, @canvas.width, @canvas.height)
		width = @map.tiled_displayed_width+1
		height = @map.tiled_displayed_height+1
		offset_tile_x = @starting_tile_x + @map.starting_tile_x
		offset_tile_y = @starting_tile_y + @map.starting_tile_y
		offset_x = Math.floor (@left_clip + @map.left_clip)
		offset_y = Math.floor (@top_clip + @map.top_clip)

		for i in [0...height]
			if (offset_tile_y + i) < @array.length
				row = i + offset_tile_y
			else	
				row = (i + offset_tile_y) - @array.length
			for j in [0...width]
				if (offset_tile_x + j) < @array[row].length
					tile = (@array[row][j + offset_tile_x])
				else
					tile = (@array[row][(offset_tile_x + j) - @array[row].length])
				if tile > 0
					tileset_x = (@map.tile_width * tile) % @tileImage.width #tileImage.width  get the x location of the tile
					tileset_y = (Math.floor((@map.tile_width * tile) / @tileImage.width )) * @map.tile_height # get y location of the tile
					canvas_x = j * (@map.tile_width * @map.scale) - offset_x # The x location where the tile will be placed on canvas
					canvas_y = i * (@map.tile_height * @map.scale) - offset_y # The y location where the tile will be placed on canvas
					@canvas.getContext("2d").drawImage(@tileImage, tileset_x, tileset_y, @map.tile_width, @map.tile_height, canvas_x, canvas_y, @map.tile_width * @map.scale, @map.tile_height * @map.scale)
		
	render: () ->
		if @horizontal_speed < 0 
			@left_clip = @left_clip - @horizontal_speed
			if @left_clip >= @map.tile_width
				@starting_tile_x = @starting_tile_x + 1
				@left_clip = @left_clip % @map.tile_width
				if @starting_tile_x == @array[0].length
					@starting_tile_x = 0
		if @horizontal_speed > 0
			@left_clip = @left_clip - @horizontal_speed
			if @left_clip <= -1
				@starting_tile_x = @starting_tile_x - 1
				@left_clip = @map.tile_width + (@left_clip + 1)
				if @starting_tile_x == -1
					@starting_tile_x = @array[0].length - 1
		if @vertical_speed < 0
				@top_clip = @top_clip - @vertical_speed
				if @top_clip >= @map.tile_height
					@starting_tile_y = @starting_tile_y + 1
					@top_clip = @top_clip - @map.tile_height
					if @starting_tile_y == @array.length
						@starting_tile_y = 0
		if @vertical_speed > 0
				@top_clip = @top_clip - @vertical_speed
				if @top_clip <= -1
					@starting_tile_y = @starting_tile_y - 1
					@top_clip = (@map.tile_height - 1) + (@top_clip + 1)
					if @starting_tile_y == -1
						@starting_tile_y = @array.length - 1

class @SequenceTileLayer extends @TileLayer
	constructor: (@map, @tile_set, @array, @sequence_array, @isStatic) ->
		super(@map, @tile_set, @array, @isStatic)
		

	render : () ->
		
	display_sequence : () ->
		for i in [0...@sequence_array.length]
			sequence_tile = @sequence_array[i]
			tile = parseInt(sequence_tile[0])
			x = parseInt(sequence_tile[2])
			y = parseInt(sequence_tile[1])
			tile_offset = parseInt(sequence_tile[3])
			frames = parseInt(sequence_tile[4])
			circular = parseInt(sequence_tile[5])
			original_tile = tile - tile_offset
			
			if sequence_tile.length < 7
				@sequence_array[i].push(tile_offset)
				@sequence_array[i].push(0)
			
			offset = @sequence_array[i][6]
			direction = @sequence_array[i][7]

			if circular == 1
				if direction == 0
					offset = offset + 1
					if offset >= frames
						offset = offset - 2
						@sequence_array[i][7] = 1
				if direction == 1
					offset = offset - 1
					if offset  < 0
						offset = 1
						@sequence_array[i][7] = 0
			if circular == 0
				offset = offset + 1
				if offset >= frames
					offset = 0
			tile = original_tile + offset
			@sequence_array[i][6] = offset
			if x >= @map.starting_tile_x and x <= @map.tiled_displayed_width + @map.starting_tile_x
				if y >= @map.starting_tile_y and y <= @map.tiled_displayed_height + @map.starting_tile_y
					tileset_x = (@map.tile_width * tile) % @tileImage.width #tileImage.width  get the x location of the tile
					tileset_y = (Math.floor((@map.tile_width * tile) / @tileImage.width )) * @map.tile_height # get y location of the tile
					canvas_x = (x - @map.starting_tile_x) * (@map.tile_width * @map.scale) - @map.left_clip # The x location where the tile will be placed on canvas
					canvas_y = (y - @map.starting_tile_y) * (@map.tile_height * @map.scale) - @map.top_clip# The y location where the tile will be placed on canvas
					@canvas.getContext("2d").drawImage(@tileImage, tileset_x, tileset_y, @map.tile_width, @map.tile_height, canvas_x, canvas_y, @map.tile_width * @map.scale, @map.tile_height * @map.scale)


	display : () ->
		width = @map.tiled_displayed_width
		height = @map.tiled_displayed_height
		@canvas.getContext("2d").clearRect(0, 0, @canvas.width, @canvas.height)
		@context.globalAlpha = 1 - @opacity
		for i in [0...height]
			if (@map.starting_tile_y + i) < @array.length
				row = i + @map.starting_tile_y
				for j in [0...width]
					if (@map.starting_tile_x + j) < @array[row].length
						tile = parseInt(@array[row][j + @map.starting_tile_x])
						if tile > 0
							tileset_x = (@map.tile_width * tile) % @tileImage.width #tileImage.width  get the x location of the tile
							tileset_y = (Math.floor((@map.tile_width * tile) / @tileImage.width )) * @map.tile_height # get y location of the tile
							canvas_x = j * (@map.tile_width * @map.scale) - @map.left_clip # The x location where the tile will be placed on canvas
							canvas_y = i * (@map.tile_height * @map.scale) - @map.top_clip# The y location where the tile will be placed on canvas
							@canvas.getContext("2d").drawImage(@tileImage, tileset_x, tileset_y, @map.tile_width, @map.tile_height, canvas_x, canvas_y, @map.tile_width * @map.scale, @map.tile_height * @map.scale)
		@display_sequence()