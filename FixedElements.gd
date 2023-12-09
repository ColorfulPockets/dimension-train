extends Control

const CAMERA_SPEED = 450

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		position.x += CAMERA_SPEED*delta
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		position.x -= CAMERA_SPEED*delta
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		position.y -= CAMERA_SPEED*delta
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		position.y += CAMERA_SPEED*delta

