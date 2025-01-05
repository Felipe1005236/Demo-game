extends Node

class_name Damageable


@export var health : float = 40 :
	get: 
		return health
	set(value):
		SignalBus.emit_signal("on_health_changed", get_parent(), value - health)
		health = value
		
var max_health = 100
		
func hit(damage : int):
	var parent = get_parent()
	health -= damage
	if parent is CharacterBody2D:
		if parent.has_method("stagger"):
			parent.stagger()
	if(health <= 0):
		if parent is CharacterBody2D:
			if parent.has_method("dead"):
				parent.dead()
