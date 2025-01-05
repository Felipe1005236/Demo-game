extends  Node2D

@export var max_health_player : float = 100
@onready var health_bar = $Player/Health_Bar

func _ready():
	SignalBus.connect("health",Callable(self, "_on_health_value"))
	
	
func _on_health_value(node : Node, health_value : int):
	print ("health value recieved:", health_value)
	if node.is_in_group("player"):
		var health_ratio = health_value / max_health_player
		print("Health ratio:", health_ratio)  
		health_bar.value = health_ratio * 100
	
	
