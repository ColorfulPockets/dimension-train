class_name DirectedGraph extends Node

# Associates an int to a node
var nodes: Dictionary

# List of directed connections between nodes
var connections: Dictionary

func _init(nodes:Dictionary = {}, connections:Dictionary = {}):
	self.nodes = nodes
	self.connections = connections

# Add the node to the dictionary of nodes
func add_node(node, id:int, from:Array[int]=[], to:Array[int]=[]):
	nodes[id] = node
	
	for from_id in from:
		connections[from_id].append(id)
	
	connections[id] = []
	for to_id in to:
		connections[id].append(to_id)

func get_connections_for_node(node_id:int):
	return connections[node_id]
