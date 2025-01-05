extends CharacterBody2D

class_name Player

@export var speed = 300
@export var gravity = 20
@export var jump_force = 300
@export var health_player = 100

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast1 = $CrouchRayCast_1
@onready var crouch_raycast2 = $CrouchRayCast_2
@onready var health_bar = $Health_Bar
@onready var DamageablePlayer = $Damageable_player
@onready var stagger_timer = $Stagger

signal facing_direction_changed(facing_right : bool)

var is_crouching = false
var stuck_under_object = false
var stand_cshape = preload("res://resources/stand_knight.tres")
var crouch_cshape = preload("res://resources/crouch_knight.tres")
var horizontal_direction = 0
var is_attacking = false
var looking_side = 0
var is_dead = false
var is_staggering = false

func _ready():
	ap.connect("animation_finished", Callable(self, "_on_animation_finished"))
	DamageablePlayer.connect("health_changed", Callable(self, "_on_health_changed"))
	print ("Player ready Initial health: ", DamageablePlayer.get_health())
	update_health_bar()
	

func _on_health_changed(new_health: float):
	print("health changed to: ", new_health)
	update_health_bar()

func update_health_bar():
	var max_health = DamageablePlayer.max_health
	var current_health = DamageablePlayer.get_health()
	print ("Updating health bar with current health: ", current_health)
	var health_ratio = current_health / max_health
	health_bar.value = health_ratio * 100
	print ("Health bar updated", current_health)

func _physics_process(delta):
	if is_dead:
		return
	
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
			velocity.y = -jump_force
	
	horizontal_direction = Input.get_axis("move_left", "move_right")
	looking_side = Input.get_axis("move_left", "move_right")
	velocity.x = speed * horizontal_direction
	
	
	if horizontal_direction != 0:
		switch_direction(horizontal_direction)
	
	if Input.is_action_just_pressed("crouch"):
		crouch()
	elif Input.is_action_just_released("crouch"):
		if above_is_empty():
			stand()
		else:
			if stuck_under_object != true:
				stuck_under_object = true
	
	if stuck_under_object && above_is_empty():
		if !Input.is_action_pressed("crouch"):
			stand()
			stuck_under_object = false
	
	basic_atack()
	
	move_and_slide()
	
	update_animations(horizontal_direction)

func above_is_empty() -> bool:
	var result = !crouch_raycast1.is_colliding() && !crouch_raycast2.is_colliding()
	return result
	
func update_animations(horizontal_direction):
	
	if is_attacking or is_staggering:
		return
	
	if is_on_floor():
		if horizontal_direction == 0:
			if is_crouching:
				ap.play("crouch")
			else:
				ap.play("idle")
		else:
			if is_crouching:
				ap.play("crouch_walk")
			else:
				ap.play("run")
	else:
		if is_crouching == false:
			if velocity.y < 0:
				ap.play("jump")
			elif velocity.y > 0:
				ap.play("fall")
		else:
			ap.play("crouch")

func switch_direction(horizontal_direction):
	if horizontal_direction > 0:
		sprite.flip_h = false
		sprite.position.x = horizontal_direction * 8
		emit_signal("facing_direction_changed", sprite.flip_h)
	else:
		sprite.flip_h = true
		sprite.position.x = horizontal_direction * 8
	
	emit_signal("facing_direction_changed", !sprite.flip_h)

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouch_cshape
	cshape.position.y = -34
	
func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = stand_cshape
	cshape.position.y = -40

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "dead":
		print("Death animation finished")
		queue_free()
	elif anim_name == "basic_attack":
		print ("Basic Attack ended")
		is_attacking = false
	elif anim_name == "hit":
		print("Hit animation ended")
		is_staggering = false 
		if is_on_floor() and !is_attacking: 
			ap.play("idle")

func basic_atack():
	if Input.is_action_just_pressed("Basic_attack"): #&& not is_attacking:
		ap.play("basic_attack")
		is_attacking = true
#
func stagger():
	if is_dead or is_staggering:
		return
	ap.play("hit")
	print ("animation for stagger played player")
	is_staggering = true
	stagger_timer.start()
	
func dead():
	print("Player died, playing 'dead' animation")  
	ap.play("dead")
	is_dead = true
	velocity = Vector2.ZERO  

func _on_stagger_timeout():
	is_staggering = false
	print ("Stagger timeout ended")
