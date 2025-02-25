extends Area2D

@export var damage : int = 10
@export var player : Player
@export var facing_collision_shape : FacingCollisionShape

func _ready():
	monitoring = false
	player.connect("facing_direction_changed", _on_player_facing_direction_changed)

func _on_body_entered(body):
	for child in body.get_children():
		if child is Damageable:
			child.hit(damage)
			print_debug (body.name + "took" + str(damage) + ".")

func _on_player_facing_direction_changed(facing_right : bool):
	if (facing_right):
		facing_collision_shape.position = facing_collision_shape.facing_right_position
	else:
		facing_collision_shape.position = facing_collision_shape.facing_left_position
