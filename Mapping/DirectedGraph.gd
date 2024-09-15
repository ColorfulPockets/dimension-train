class_name DirectedGraph extends Node

# Associates an int to a node
var nodes: Array

# List of directed connections between nodes
var connections: Dictionary

func _init(nodes:Array = [], connections:Dictionary = {}):
	self.nodes = nodes
	self.connections = connections

func size():
	return nodes.size()
	

# Add the node to the dictionary of nodes
func add_node(node, from:Array=[], to:Array=[]):
	nodes.append(node)
	for prevNode in from:
		add_connection(prevNode, node)
	
	connections[node] = []
	for nextNode in to:
		add_connection(node, nextNode)

func add_connection(node1, node2):
	connections[node1].append(node2)

func get_connections_for_node(node):
	if node in connections.keys():
		return connections[node]
	
	return []
