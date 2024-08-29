extends TextureRect

func addSegment(dimension:String, index:int):
	var texture = load("res://Assets/UI/Dimension Wheel/" + dimension + " Wheel Segment.png")
	var segment:TextureRect = TextureRect.new()
	segment.size = size/2
	segment.position += segment.size
	segment.texture = texture
	
	match index:
		0:
			segment.scale.x *= -1
			segment.position.x += segment.size.x
			segment.position.y -= segment.size.y
		1:
			segment.rotation += PI/2
			segment.position.x += segment.size.x
			segment.position.y -= segment.size.y
		2:
			segment.rotation += PI/2
			segment.scale.x *= -1
			segment.position += segment.size
		3:
			segment.rotation += PI
			segment.position += segment.size
		4:
			segment.rotation += PI
			segment.scale.x *= -1
			segment.position.x -= segment.size.x
			segment.position.y += segment.size.y
		5:
			segment.rotation += 3*PI/2
			segment.position.x -= segment.size.x
			segment.position.y += segment.size.y
		6:
			segment.rotation += 3*PI/2
			segment.scale.x *= -1
			segment.position -= segment.size
		7:
			segment.position -= segment.size
	
	add_child(segment)
	
	var iconTexture = load("res://Assets/UI/Dimension Wheel/" + dimension + " Icon.png")
	var icon:TextureRect = TextureRect.new()
	icon.scale *= 0.35
	icon.position = segment.size/2 
	icon.texture = iconTexture
	icon.rotation -= segment.rotation
	segment.add_child(icon)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Stats.dimensionWheelSegments.size()):
		addSegment(Stats.dimensionWheelSegments[i], i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
