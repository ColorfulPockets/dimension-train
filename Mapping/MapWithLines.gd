extends HBoxContainer

var lines:Array[PackedVector2Array] = []
var lineRewards = []

var waterCheckTexture = preload("res://Assets/Icons/Water Check.png")
var moneyBagTexture = preload("res://Assets/Icons/MoneyBag.png")

func drawMap(layers):
	var separation_damping = 0.5
	var outDegree_damping = 0.5
	var vBoxes = []
	var maxLayerSize = 0
	var prevOutDegreeScore = 0
	for layer:Array in layers:
		if layer == layers[-1]:
			if prevOutDegreeScore > 1:
				for i in range(floor(prevOutDegreeScore)):
					layer.push_back(MapRewards.new("Spacer", false, []))
			else:
				for i in range(floor(abs(prevOutDegreeScore))):
					layer.push_front(MapRewards.new("Spacer", false, []))
			maxLayerSize = max(layer.size(), maxLayerSize)
			continue
		
		var middleNode = float(layer.size()) / 2
		var outDegreeScore = 0
		for i in range(layer.size()):
			var node = layer[i]
			outDegreeScore += outDegree_damping*(i-middleNode) * Overworld.graph.get_out_degree(node)
		
		prevOutDegreeScore = outDegreeScore
		
		if outDegreeScore > 1:
			for i in range(floor(outDegreeScore)):
				layer.push_back(MapRewards.new("Spacer", false, []))
		else:
			for i in range(floor(abs(outDegreeScore))):
				layer.push_front(MapRewards.new("Spacer", false, []))
		
		maxLayerSize = max(layer.size(), maxLayerSize)
	
	var nodeHeight = layers[0][0].custom_minimum_size.y
	var maxHeight = maxLayerSize * nodeHeight + (maxLayerSize-1)*100
	
	for layer in layers:
		var layerHeight = layer.size() * nodeHeight + (layer.size()-1)*100
		var separation = 100 + separation_damping*(maxHeight - layerHeight)/(layer.size())
		var vBoxContainer = VBoxContainer.new()
		vBoxContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
		vBoxContainer.add_theme_constant_override("separation", separation)
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
			if reward[1] in TrainCar.allCars:
				var percentageAlongLine = 0.65
				var trainCarReward = TrainCar.new(reward[1], "Path reward:\n")
				trainCarReward.position = line[0] + percentageAlongLine * (line[1] - line[0])
				trainCarReward.position += self.position
				trainCarReward.scale *= 3.5
				get_parent().add_child(trainCarReward)
			elif reward[1] == "MoneyBag":
				var moneyBagContainer = Node2D.new()
				var moneyBagIcon = TextureRect.new()
				var textureSize = Vector2(50,50)
				var percentageAlongLine = 0.65
				moneyBagIcon.texture = moneyBagTexture
				moneyBagIcon.custom_minimum_size = textureSize
				moneyBagIcon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				moneyBagIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				moneyBagContainer.position = line[0] + percentageAlongLine * (line[1] - line[0])
				moneyBagContainer.position -= textureSize/2
				moneyBagContainer.position += self.position
				get_parent().add_child(moneyBagContainer)
				moneyBagContainer.add_child(moneyBagIcon)
				
				var tooltip = Tooltip.new("Path reward:\nExtra money and emergency rail.")
				tooltip.visuals_res = load("res://tooltip.tscn")
				moneyBagIcon.add_child(tooltip)
