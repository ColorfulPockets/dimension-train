extends Control

const CAMERA_SPEED = 1200

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Global.VIEWPORT_SIZE
	
	$DiscardPile.scale *= 0.45
	$DiscardPile.position = Global.DISCARD_PILE_POSITION
	
	$DrawPile.scale *= 0.45
	$DrawPile.position = Global.DRAW_PILE_POSITION


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

