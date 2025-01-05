extends Node
@export var max_health_player : float = 100

signal on_health_changed(node : Node, amount_changed : int)
signal health(node : Node, health_value : int)


func _ready():
	print ("Signal Bus ready")
#func emit_health_changed(node : Node, amount_changed : int):
#	emit_signal("on_health_changed", node, amount_changed)
#	emit_signal("health", node, node.health)
