extends VBoxContainer


func optionSelected(selectedOptionPanelNode):
	for i in range(1,4):
		var optionPanelNode = get_node("HBoxContainer/OptionsContainer/Option" + str(i) + "/Panel")
		if optionPanelNode != selectedOptionPanelNode:
			optionPanelNode.deselect()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
