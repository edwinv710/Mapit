# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class @Map
	constructor: (@map, @canvas_width, @canvas_height, @scale) ->
		@width_to_height = (@canvas_width / @canvas_height)
		@tiled_width = @map.width 
		@tiled_height = @map.height
		@tile_width = @map.tile_width 
		@tile_height = @map.tile_height
		@width = @tiled_width * @tile_width * @scale
		@height = @tiled_height * @tile_height * @scale
		@tileImage = document.querySelectorAll(".tileset")
		@starting_tile_x = 0
		@starting_tile_y = 0
		@left_clip = 0
		@top_clip = 0
		@tiled_width_capacity =  Math.floor((@canvas_width / @scale) / @tile_width)
		@tiled_height_capacity = Math.floor((@canvas_height / @scale) / @tile_height)
		@focal_x = 0
		@focal_y = 0
		@layers = new Array()
		@fps = 30
		@resize()
		@x_move = 0
		@y_move = 0
		@can_move = true

	import_layers: (layers) ->
		for i in [0...layers.length]
			if layers[i]["is_tile_layer"] == true
				if layers[i]["sequence_array"] != null
					layer = new SequenceTileLayer(@, layers[i]["tileset_id"], layers[i]["array"], layers[i]["sequence_array"])
					@add_layer(layer)
				else if layers[i]["is_scrolling"] == true
					if layers[i]["is_tile_scroll"] == true
						layer = new TileScrollLayer(@, layers[i]["tileset_id"], layers[i]["array"], layers[i]["horizontal_speed"], layers[i]["vertical_speed"])
						@add_layer(layer)
					else
						layer = new ScrollingTileLayer(@, layers[i]["tileset_id"], layers[i]["array"], layers[i]["horizontal_speed"], layers[i]["vertical_speed"])
						@add_layer(layer)
				else
					layer = new TileLayer(@, layers[i]["tileset_id"], layers[i]["array"], layers[i]["is_static"], layers[i]["horizontal_speed"], layers[i]["vertical_speed"], layers[i]["is_tile_scroll"])
					@add_layer(layer)
				if layers[i]["opacity"] != null
					layer.set_opacity(layers[i]["opacity"])		
			else if layers[i]["is_fill_layer"] == true
				layer = new FillLayer(@, layers[i]["background_color"], layers[i]["opacity"])
				@add_layer(layer)
			else if layers[i]["image"] != null
				new_layer = new ImageLayer(@, layers[i]["image"], layers[i]["is_x_repeat"], layers[i]["is_y_repeat"], layers[i]["is_x_stretch"], layers[i]["is_y_stretch"], layers[i]["is_static"])
				@add_layer(new_layer)

	set_move : (x_speed, y_speed) ->
		@x_move = @x_move + x_speed
		@y_move = @y_move + y_speed
		@can_move = false

	add_background_color: (color) ->
		if color.length > 2
			layer = new FillLayer(this, color, 1)
			@layers.push(layer)

	add_tile_layer: (tile, tile_set, x_speed, y_speed, fps) ->
		array_x = new Array(@tiled_width)
		for i in [0...array_x.length]
			array_x[i] = tile
		array = new Array()
		for i in [0...@tiled_height]
			array.push(array_x)
		layer = @add_layer(array, tile_set, true)	
		@layers.push(layer)
		if arguments.length > 1
			layer.display_scrolling_layer(x_speed, y_speed, fps)

	add_layer: (layer_array, tile_set, isStatic) ->
		if arguments.length == 3
			layer = new Layer(this, tile_set, layer_array, isStatic)
			@layers.push(layer)
		else if arguments.length == 1
			@layers.push(layer_array)
			layer = layer_array
		return layer

	add_layers: (layer_array, isStatic) ->
		if arguments.length == 1
			for i in [0...layer_array.length]
				@add_layer(layer_array[i])  
		else if arguments.length == 2
			for i in [0...layer_array.length]
				@add_layer(layer_array[i], isStatic[i])                 

	moveScreen: (x_amount, y_amount) ->
		console.log(@starting_tile_x)
		console.log(@tiled_width)
		console.log(@tiled_width_capacity)
		prev_left_clip = @left_clip
		prev_top_clip = @top_clip
		prev_starting_tile_x = @starting_tile_x
		prev_starting_tile_y = @starting_tile_y
		starting_tile_x_change = 0
		starting_tile_y_change = 0

		@left_clip = @left_clip + x_amount
		@top_clip = @top_clip + y_amount

		if @left_clip >= @tile_width 
			starting_tile_x_change = Math.floor(@left_clip / @tile_width)
			@left_clip = @left_clip % @tile_width
			@starting_tile_x = @starting_tile_x + starting_tile_x_change
		

		if @top_clip >=  @tile_height 
			starting_tile_y_change = Math.floor(@top_clip / @tile_height)
			@top_clip = @top_clip % @tile_height
			@starting_tile_y = @starting_tile_y + starting_tile_y_change

		if @left_clip < 0 
				starting_tile_x_change = Math.floor(@left_clip / @tile_width)
				@left_clip = (@tile_width - 1) + @left_clip
				@starting_tile_x = @starting_tile_x + starting_tile_x_change
				if @starting_tile_x < 0
					@starting_tile_x = 0
					@left_clip = 0

		if @top_clip < 0 
			starting_tile_y_change = Math.floor(@top_clip / @tile_height)
			@top_clip = (@tiled_height - 1) + @top_clip
			@starting_tile_y = @starting_tile_y + starting_tile_y_change
			if @starting_tile_y < 0
				@starting_tile_y = 0
				@top_clip = 0


		if @starting_tile_y >= (@tiled_height - @tiled_height_capacity)
			if @top_clip > 0 || @starting_tile_x > (@tiled_height - @tiled_height_capacity)
				@starting_tile_y = @tiled_height - @tiled_height_capacity
				@top_clip = 0

		if @starting_tile_x >= (@tiled_width - @tiled_width_capacity)
			if @left_clip > 0 || @starting_tile_x > (@tiled_width - @tiled_width_capacity)
				@starting_tile_x = @tiled_width - @tiled_width_capacity
				@left_clip = 0

		if prev_left_clip != @left_clip || prev_top_clip != @top_clip || prev_starting_tile_y != @starting_tile_y || prev_starting_tile_x != @starting_tile_x
			for i in [0...@layers.length]
				@layers[i].update = true

	setFocalPoint: (x, y) ->
		map_x = x - (@canvas_width / 2).ceil
		map_y = y - (@canvas_height / 2).ceil

		mid_x = (@canvas_width / 2)
		mid_y = (@canvas_height / 2)
		
		if (x >= 0) && (x <= @width)
			if x > mid_x 
				if x < (@width - mid_x)
					@starting_tile_x = Math.floor((x - mid_x) / (@tile_width* @scale))
					@left_clip = ((x - mid_x) % (@tile_width * @scale))
				else
					@starting_tile_x = Math.floor((@width - @canvas_width) / (@tile_width* @scale))
					@left_clip = ((@width - @canvas_width) % (@tile_width * @scale))
			if x < mid_x
				if @left_clip != 0
					@starting_tile_x = 0
					@left_clip = 0 
			@focal_x = x


		if  (y >= 0) && (y <= @height)
			if y > mid_y
				if y < (@height - mid_y)
					@starting_tile_y = Math.floor((y - mid_y) / (@tile_height * @scale))
					@top_clip = ((y - mid_y) % (@tile_height * @scale))
				else
					@starting_tile_y = Math.floor((@height - @canvas_height) / (@tile_height* @scale))
					@top_clip = ((@height - @canvas_height) % (@tile_height * @scale))
			if y < mid_y
				if @top_clip != 0
					@starting_tile_y = 0
					@top_clip = 0 
			@focal_y = y

	display_map:  ->
		self = this
		interval = 1000 / @fps

		@tiled_displayed_width = @tiled_width_capacity
		@tiled_displayed_height = @tiled_height_capacity

		if @starting_tile_x + @tiled_width_capacity < @tiled_width
			@tiled_displayed_width = @tiled_displayed_width + 1
		if @starting_tile_y + @tiled_height_capacity < @tiled_height
			@tiled_displayed_height = @tiled_displayed_height + 1

		self.set = setInterval(-> 
			if self.x_move != 0
				self.moveFocalPoint self.focal_x + self.x_move, self.focal_y
				self.x_move = 0
				self.can_move = true
			if self.y_move != 0
				self.moveFocalPoint self.focal_x, self.focal_y + self.y_move
				self.y_move = 0
				self.can_move = true

			for k in [0...self.layers.length]
				self.layers[k].render()
			for k in [0...self.layers.length]
				self.layers[k].display()
		, interval)

	set_scale: (scale) ->
		f_scale = scale / @scale
		@scale = scale
		@width = @tiled_width * @tile_width * @scale
		@height = @tiled_height * @tile_height * @scale
		@tiled_width_capacity =  Math.ceil((@canvas_width / @scale) / @tile_width)
		@tiled_height_capacity = Math.ceil((@canvas_height / @scale) / @tile_height)
		@setFocalPoint(Math.ceil((@focal_x * f_scale)), Math.ceil((@focal_y * f_scale)))
		@display_map()

	resize: (ref) ->
		if arguments.length == 0
		    ref = @

		game = document.querySelector('#game')
		window_width = window.innerWidth
		window_height = window.innerHeight
		width_to_height = window_width / window_height

		if width_to_height > ref.width_to_height 
		    window_width = window_height * ref.width_to_height
		else
			window_height = window_width / ref.width_to_height

		game.style.height = window_height + 'px'
		game.style.width = window_width + 'px'

		game.style.marginTop = (-window_height / 2) + 'px';
		game.style.marginLeft = (-window_width / 2) + 'px';


Map.start = (id) ->
	map = 0
	images = document.querySelectorAll(".tileset")
	load_game = ->
		keyDownListener = (e) ->
			code = e.keyCode
			switch code
			  when 37 #Left key
			  	if map.can_move
			      map.moveScreen(-8, 0)
			  when 38 #Up key
			    if map.can_move
			      map.moveScreen(0, -8)
			      e.preventDefault()
			  when 39 #Right key
			    if map.can_move
			      map.moveScreen(8, 0)
			  when 40 #Down key
			    if map.can_move
			      map.moveScreen(0, 8)
			      e.preventDefault()
		
		$.getJSON id, (data) ->
		  map = new Map(data, data.container_width, data.container_height, 1)
		  
		  $.getJSON id+"/layers", (layers) ->
		  	map.import_layers(layers)
		  	map.display_map()
		  
		  	panel = new Panel(map)
		  	map.layers[map.layers.length - 1].canvas.addEventListener "keydown", keyDownListener, false
		  	window.addEventListener 'resize', -> 
		  		map.resize(map) 
		  	,false
		  	window.addEventListener 'orientationchange', ->
		  		map.resize(map)
		  	,false
	$('.tileset').on('load', load_game)

