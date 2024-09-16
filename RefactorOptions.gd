extends Panel

var currently_selected = false
var mouseOver = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self_modulate.a = 0
	
	mouse_entered.connect(func():
		mouseOver = true
		if not currently_selected:
			self_modulate.a = 1
			self_modulate.b = 0
		)
		
	mouse_exited.connect(func():
		mouseOver = false
		if not currently_selected:
			self_modulate.a = 0
		)

func select():
	self_modulate.a = 1
	self_modulate.b = 1
	self_modulate.r = 0
	self_modulate.g = 0
	currently_selected = true

func deselect():
	currently_selected = false
	self_modulate.a = 0
	self_modulate.b = 1
	self_modulate.r = 1
	self_modulate.g = 1

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if mouseOver:
			$"../../../../".optionSelected(self)
			select()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
