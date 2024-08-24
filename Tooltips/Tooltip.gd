class_name Tooltip
extends Node


#####################################
# SIGNALS
#####################################

#####################################
# CONSTANTS
#####################################

#####################################
# EXPORT VARIABLES 
#####################################
@export_range (0, 10, 0.05) var delay: float = 0.01
@export var follow_mouse: bool = true
@export_range (0, 100, 1) var offset_x: float = 50
@export_range (0, 100, 1) var offset_y: float = 50
@export_range (0, 100, 1) var padding_x: float = 10
@export_range (0, 100, 1) var padding_y: float = 10


#####################################
# PUBLIC VARIABLES 
#####################################

#####################################
# PRIVATE VARIABLES
#####################################
var _visuals: Control
var _timer: Timer


#####################################
# ONREADY VARIABLES
#####################################
@onready var visuals_res: PackedScene = load("res://Tooltips/tooltip.tscn")
@onready var owner_node = get_parent()
@onready var offset: Vector2 = Vector2(offset_x, offset_y)
@onready var padding: Vector2 = Vector2(padding_x, padding_y)
@onready var extents: Vector2

var text
var fixedElementsLayersUp:int
var textIsCallable:bool = false

#####################################
# OVERRIDE FUNCTIONS
#####################################
func _init(text, fixedElementsLayersUp:int, textIsCallable:bool = false) -> void:
	self.textIsCallable = textIsCallable
	self.text = text
	self.fixedElementsLayersUp = fixedElementsLayersUp


func _ready() -> void:
	# create the visuals
	_visuals = visuals_res.instantiate()
	add_child(_visuals)
	# calculate the extents
	extents = _visuals.size
	# connect signals
	owner_node.connect("mouse_entered", _mouse_entered)
	owner_node.connect("mouse_exited", _mouse_exited)
	
	# initialize the timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _custom_show)
	# default to hide
	_visuals.hide()


func _process(delta: float) -> void:
	if _visuals.visible:
		if textIsCallable:
			$"./Tooltip/Label".text = self.text.call()
		else:
			$"./Tooltip/Label".text = self.text
		var border = Vector2(get_viewport().size) - padding
		extents = $"./Tooltip".size
		var base_pos = _get_screen_pos()
		# test if need to display to the left
		var final_x = base_pos.x + offset.x
		if final_x + extents.x > border.x:
			final_x = base_pos.x - offset.x - extents.x
		# test if need to display below
		var final_y = base_pos.y - extents.y - offset.y
		if final_y < padding.y:
			final_y = base_pos.y + offset.y
		var layersUpString = ""
		for i in range(fixedElementsLayersUp):
			layersUpString += "../"
		layersUpString += "FixedElements"
		$"./Tooltip".position = Vector2(final_x, final_y) + get_node(layersUpString).position

#####################################
# API FUNCTIONS
#####################################

#####################################
# HELPER FUNCTIONS
#####################################
func _mouse_entered() -> void:
	#print("MOUSE ENTERED")
	_timer.start(delay)


func _mouse_exited() -> void:
	#print("MOUSE EXITED")
	_timer.stop()
	_visuals.hide()


func _custom_show() -> void:
	#print("SHOWING")
	_timer.stop()
	_visuals.show()


func _get_screen_pos() -> Vector2:
	if follow_mouse:
		return get_viewport().get_mouse_position()
	
	
	var position = Vector2()
	
	if owner_node is Node2D:
		position = owner_node.get_global_transform_with_canvas().origin
	elif owner_node is Node3D:
		position = get_viewport().get_camera().unproject_position(owner_node.global_transform.origin)
	elif owner_node is Control:
		position = owner_node.rect_position
	
	return position

func _exit_tree():
	owner_node.disconnect("mouse_entered", _mouse_entered)
	owner_node.disconnect("mouse_exited", _mouse_exited)
