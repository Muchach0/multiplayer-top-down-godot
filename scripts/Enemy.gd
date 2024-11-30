class_name Enemy
extends KinematicBody2D

export var MAX_DEFAULT_HEALTH = 3
const DEFAULT_SCORE = 1

onready var animation_player_action_player = $AnimationPlayerActionPlayer # for the action of the player on the enemy (hit, die)
onready var animation_player_action_enemy = $AnimationPlayerActionEnemy # for all the actions of the enemy (move, attack, spells)

onready var timer := $Timer # timer to queue_free the enemy on dying
onready var timer_glow := $TimerGlow
onready var collision_shape := $CollisionShape2D

# onready var toto:= $toto if has_node("toto") else null # 
onready var health_component := $HealthComponent if has_node("HealthComponent") else null

# onready var world = get_node("/root/World")
onready var sprite := $Sprite
export var should_flip_sprite: bool = false

var health
var score_given_by_this_enemy = DEFAULT_SCORE

# MOVING ENNEMY PART
# Define enemy states
# enum State { IDLE, AGGRO, ATTACK, DYING }
# var current_state = State.IDLE
# var is_moving = true # boolean to see if the ennemy is going to the target position
var player = null
export var speed: float = 100  # Movement speed in pixels per second
# var attack_range = 50 # Range within which enemy attacks

export var should_be_able_to_move = true

# Attacking part
var is_attack_on_cooldown = false
onready var timer_attack_cooldown := $TimerAttack
onready var hitbox := $HitBox
onready var hitbox_collision_shape := $HitBox/CollisionShape2D
onready var hurtbox_collision_shape := $HurtBox/CollisionShape2D

puppet var puppet_position = Vector2()

signal enemy_died

func _ready() -> void:
	timer.connect("timeout", self, "queue_free") # When timer expired, free the ennemy
	timer_glow.connect("timeout", self, "stop_glow") # When timer expired, stop glowing
	health = MAX_DEFAULT_HEALTH

	if health_component != null:
		health_component.init_life_bar(MAX_DEFAULT_HEALTH)
	# animation_player_action_player.play("Idle")

	# Duplicate the shader to make individual modification
	sprite.material = sprite.material.duplicate()

	# Attack part
	hitbox.connect("attack_landed", self, "attack_landed")
	timer_attack_cooldown.connect("timeout", self, "reset_cooldown")

func flip_sprite(flip: bool) -> void:
	if not should_flip_sprite: # do nothing if the enemy should not flip the sprite
		return
	sprite.flip_h = flip
	for child_sprite in sprite.get_children():
		child_sprite.flip_h = flip 

# ================ TAKING DAMAGE PART ================
func stop_glow() -> void:
	sprite.material.set_shader_param("use_red_color", false)
	sprite.material.set_shader_param("use_green_color", false)

func start_red_glow() -> void:
	sprite.material.set_shader_param("use_red_color", true)
	timer_glow.start()


# Function to sync damage to all the peers (from the master of the node).
# The Enemy is supposed to always be owned by the server! (so server == master of the node).
# This is in 'remotesync' mode because we want also to use that function on the master.
remotesync func sync_damage(damage: int, from_player_id:int, health_from_server: int) -> void:
	print("Enemy.gd - sync_damage - damage: ", damage, " - from_player_id: ", from_player_id, " - health_from_server: ", health_from_server)
	health = health_from_server
	animation_player_action_player.stop(true)
	animation_player_action_player.play("Hit")
	health -= damage
	
	# Check if health_component is null or not:
	if health_component != null:
		health_component.update_life_bar(health, damage)
	
	start_red_glow()
	if health <= 0:
		# Emit signal from state machine
		$StateMachine.current_state.emit_signal("transitioned", $StateMachine.current_state, "EnemyDying")
		die(from_player_id)

remotesync func take_damage(damage: int, from_player_id: int) -> void:
	# If we are in network mode, and this node is the master, then we sync the damage to everybody.
	if EventBus.is_in_network_mode() && is_network_master():
		print_debug("Server is seding sync_damage to all peers:", damage, from_player_id, health)
		rpc("sync_damage", damage, from_player_id, health)
	elif not EventBus.is_in_network_mode(): # If we are not in network mode, we just take the damage locally
		sync_damage(damage, from_player_id, health)
	# If we are in network mode, and this node is not the master, then we do nothing as the master will sync the damage to everybody.

# Not sure if that should be part of the enemy script or the EnemyDying script. 
# Keeping it here for now as it is related to the enemy damage above.
func die(_from_player_id: int) -> void:
	print_debug("Enemy.gd - die - Enemy ", self, " is dying by player ", _from_player_id)
	# current_state = State.DYING
	collision_shape.set_deferred("disabled", true) # Disabling the collision shape when the ennemy is dying
	hitbox_collision_shape.set_deferred("disabled", true) # Disabling the hitbox when the ennemy is dying
	hurtbox_collision_shape.set_deferred("disabled", true) # Disabling the hurtbox when the ennemy is dying

	emit_signal("enemy_died")
	EventBus.emit_signal("one_enemy_die")
	EventBus.emit_signal("update_score", score_given_by_this_enemy, _from_player_id)
	# update_score()
	animation_player_action_player.stop(true)
	animation_player_action_enemy.stop(true)
	animation_player_action_player.play("Die")
	# hurt_box.disabled = true
	# $Sprite.visible = false
	timer.start()


#================ ATTACK PART ================
func attack_landed():
	print_debug("Enemy.gd - attack_landed - setting up the cooldown")
	is_attack_on_cooldown = true
	hitbox_collision_shape.set_deferred("disabled", true) # Disabling the hitbox when we landed an attack
	# hitbox_collision_shape.disabled = true
	timer_attack_cooldown.start()

func reset_cooldown():
	print_debug("Enemy.gd - reset_cooldown - reseting cooldown")
	is_attack_on_cooldown = false
	hitbox_collision_shape.set_deferred("disabled", false) # Disabling the hitbox when we landed an attack
	# hitbox_collision_shape.disabled = false
	
	# hitbox.set_deferred("disabled", false) # Re-enabling the hitbox after the cooldown is finished
