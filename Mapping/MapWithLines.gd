extends HBoxContainer

var lines:Array[PackedVector2Array] = []
var lineRewards = []

var waterCheckTexture = preload("res://Assets/Icons/Water Check.png")

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
		for node:MapRewards in layer:
			for next_connection in Overworld.graph.get_connections_for_node(node):
				var next_node = next_connection[0]
				var connection_reward = next_connection[1]
				var line:PackedVector2Array = []
				line.append(node.global_position + Vector2(node.size.x*1, node.size.y/2) - global_position)
				line.append(next_node.global_position + Vector2(next_node.size.x*0, next_node.size.y/2) - global_position)
				
				lines.append(line)
				lineRewards.append(connection_reward)
				
	queue_redraw()

func _draw():
	for i in range(lines.size()):
		var line = lines[i]
		var reward = lineRewards[i]
		draw_polyline(line, Color.WHITE, 5)
		if reward.size() > 0:
			if reward[0] == "WaterCheck":
				var waterCheckIconContainer = Node2D.new()
				var waterCheckIcon = TextureRect.new()
				var textureSize = Vector2(50,50)
				var percentageAlongLine = 0.35
				waterCheckIcon.texture = waterCheckTexture
				waterCheckIcon.custom_minimum_size = textureSize
				waterCheckIcon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				waterCheckIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				waterCheckIconContainer.position = line[0] + percentageAlongLine * (line[1] - line[0])
				waterCheckIconContainer.position -= textureSize/2
				waterCheckIconContainer.position += self.position
				get_parent().add_child(waterCheckIconContainer)
				waterCheckIconContainer.add_child(waterCheckIcon)
				
				var tooltip = Tooltip.new("Crossing water is necessary to take this path.")
				tooltip.visuals_res = load("res://tooltip.tscn")
				waterCheckIcon.add_child(tooltip)
