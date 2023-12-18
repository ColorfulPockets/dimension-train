class_name MapNode extends Sprite2D

var clickable = false
var map = null
signal map_selected(mapName)

# This function is called when the sprite is clicked
func clicked():
	if clickable:
		map_selected.emit(map)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Get the mouse position
				var mouse_position = get_global_mouse_position()

				# Check if the mouse is over the sprite
				if Rect2(position-texture.get_size()/2, texture.get_size()).has_point(mouse_position):
					# Call the clicked function when the sprite is clicked
					clicked()
