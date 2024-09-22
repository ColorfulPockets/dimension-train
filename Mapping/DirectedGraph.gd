class_name DirectedGraph extends Node

# Associates an int to a node
var nodes: Array

# connections[Node] = [ConnectedNode, Value of Connection]
var connections: Dictionary

func _init(nodes:Array = [], connections:Dictionary = {}):
	self.nodes = nodes
	self.connections = connections

func size():
	return nodes.size()
	

# Add the node to the dictionary of nodes
# From and To should be arrays of sub-arrays with [Node, ConnectionValue]
func add_node(node, from:Array=[], to:Array=[]):
	nodes.append(node)
	for prevNode in from:
		add_connection(prevNode[0], node, prevNode[1])
	
	connections[node] = []
	for nextNode in to:
		add_connection(node, nextNode[0], nextNode[1])

func add_connection(node1, node2, connectionValue):
	connections[node1].append([node2, connectionValue])

func get_connections_for_node(node):
	if node in connections.keys():
		return connections[node]
	
	return []

func get_out_degree(node):
	if node in connections.keys():
		return connections[node].size()
	else:
		return 0
