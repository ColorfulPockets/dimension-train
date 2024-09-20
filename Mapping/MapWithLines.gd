extends HBoxContainer

var lines:Array[PackedVector2Array] = []
var lineRewards = []

func drawMap(layers):
	for layer in layers:
		var vBoxContainer = VBoxContainer.new()
		vBoxContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
		vBoxContainer.add_theme_constant_override("separation", 100)
		for node:MapRewards in layer:
			vBoxContainer.add_child(node)
		
		add_child(vBoxContainer)
	
	await get_tree().create_timer(0.1).timeout
	for layer in layers:
		for node in layer:
			for next_node in Overworld.graph.get_connections_for_node(node):
				var line:PackedVector2Array = []
				line.append(node.global_position + Vector2(node.size.x*1, node.size.y/2) - global_position)
				line.append(next_node.global_position + Vector2(next_node.size.x*0, next_node.size.y/2) - global_position)
				
				lines.append(line)
				
	queue_redraw()
				

func _draw():
	for line in lines:
		draw_polyline(line, Color.WHITE, 5)
