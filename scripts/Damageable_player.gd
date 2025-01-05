extends Node

class_name Damageable_player

@export var max_health = 100

var health: float = max_health
var is_dead: bool = false

signal health_changed (new_health : float)

@export var _health : float = 100 :
	get: 
		return health
	set(value):
		if is_dead:
			return
		var old_health = _health
		_health = clamp(value, 0, max_health)
		if old_health != _health:
			SignalBus.emit_signal("on_health_changed", get_parent(), _health)
			print("Emmitting health_changed signal with new health")
			emit_signal("health_changed", _health)


func _ready():
	print ("Damageable player ready")
	SignalBus.connect("on_health_changed", Callable(self, "_on_health_changed"))

func hit(damage : int):
	if is_dead:
		return
	health -= damage
	print("Player hit, health: ", _health)
	if _health <= 0:
		if get_parent().has_method("dead"):
			is_dead = true 
			get_parent().dead()
	else:
		if get_parent().has_method("stagger"):
			get_parent().stagger()
	emit_signal("health_changed", _health)


func _on_health_changed(node : Node, new_health: int):
	if node == get_parent():
		print("Health changed for node: ", node.name, " New Health: ", new_health)
		emit_signal("health_changed", new_health)

func get_health() -> float:
	return _health
	
func set_health(value: float):
	health = clamp(value, 0, max_health)
