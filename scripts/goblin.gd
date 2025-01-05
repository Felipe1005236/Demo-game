extends CharacterBody2D

@export var speed = 100
@export var gravity = 20
@export var attack_distance = 25

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var stagger_timer = $Stagger

var player_chase = false
var player = null 
var is_attacking = false
var looking_side = 0
var is_dead = false

func _ready():
	ap.connect("animation_finished", Callable(self, "_on_AnimationPlayer_animation_finished"))

func _physics_process(_delta):
	if is_dead:
		return
	
	if not is_attacking:
		if player_chase && player != null:
			var distance_to_player = position.distance_to(player.position)
			if distance_to_player > attack_distance:
				var direction = (player.position - position).normalized()
				velocity.x = direction.x * speed
				if looking_side != 0 && player_chase == true:
					ap.play("run")
			else:
				velocity.x = 0
				if is_on_floor():
					ap.play("attack")
					is_attacking = true
					

	if !is_on_floor():
		velocity.y += gravity
	if velocity.y > 1000:
		velocity.y = 1000
	
	if player != null:
		looking_side = 1 if player.position.x > position.x else -1
	
	if looking_side != 0:
		switch_direction(looking_side)
	
	move_and_slide()
	
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player = null 
		player_chase = false
		velocity.x = 0
		if is_on_floor():
			ap.play("idle")
		is_attacking = false

func switch_direction(looking_side):
	sprite.flip_h = (looking_side == -1)

func dead():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO  # Stop movement
	print("Goblin died, playing 'dead' animation")  # Debug print
	ap.play("dead")

func stagger():
	if is_dead:
		return
	ap.play("hit")
	stagger_timer.start()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "dead":
		print("Death animation finished")
		queue_free()
	
func _on_stagger_timeout():
	if is_dead:
		return
	
	if player != null:
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player <= attack_distance:
			player_chase = true
			ap.play("run")
		else:
			ap.play("idle")  
			player_chase = false
	
	is_attacking = false
  
