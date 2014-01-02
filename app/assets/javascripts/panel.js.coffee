class @Panel
	constructor: (@map) ->

		form_dom = $("<form></form>")
		for i in [0...@map.layers.length]
			string = 'Layer '+(i+1)
			text_dom = $("<b> "+(i+1)+"</b>")
			checkbox_dom = $("<input type='checkbox' name='"+string+"' value='"+i+"' checked>")
			$(form_dom).append(text_dom)
			$(form_dom).append(checkbox_dom)
		section_dom = document.querySelector('.layer_collection')
		$(section_dom).append(form_dom)
		form_dom = $("<form></form>")
		#scale_dom = $( "<input  type='number' name='scale' min='.5' max='5' step = '.5' value = '"+@map.scale+"'>")
		#$(form_dom).append(scale_dom)
		#section_dom = document.querySelector('.scale_container')
		#$(section_dom).append(form_dom)

		$('.scale_container input').change(->
			value = $('.scale_container input').val()
			console.log('Scale changed to '+value)
			map.set_scale(value)
			)

		$('.layer_collection input').change(->
			checked = $(this).prop('checked')
			layer = $(this).prop('value')
			map.layers[parseInt(layer)].set_display(checked)
			)

		$('.map_collection select').change( ->
			root = window.location.protocol + '//' + window.location.host
			id = $(this).prop('value')
			window.location = (root+'/maps/'+id)
			)

