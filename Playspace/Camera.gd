extends Camera2D

const CAMERA_SPEED = 1200
var controlled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Stats.camera_controlled.connect(func(set_controlled):
		if not set_controlled:
			position = Vector2(0,0)
		self.controlled = set_controlled
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not controlled:
		return
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		position.x += CAMERA_SPEED*delta
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		position.x -= CAMERA_SPEED*delta
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		position.y -= CAMERA_SPEED*delta
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		position.y += CAMERA_SPEED*delta
