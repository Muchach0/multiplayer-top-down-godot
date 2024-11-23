class_name MyPlayer
extends KinematicBody2D


export var MOTION_SPEED = 150.0
const MAX_HEALTH = 5
const CHARACTER_INDEX_TO_PATH = {
	1: "res://assets/charwalk.png",
	2: "res://assets/betty.png"
}

# Motion and direction for the player
var motion = Vector2()
var direction = Vector2() # Direction of the player (used for the rotation of the player)
var should_cast_spell_1 = false
var bomb_name = ""


puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
puppet var puppet_direction = Vector2()

export var stunned = false

onready var _pivot := $Pivot # Pivot to rotate --> this is used to rotate the player sprite, (so not including the UI)
onready var shoot_position := $Pivot/ShootPosition 
onready var health_component := $HealthComponent

# Shader part
onready var timer_glow := $TimerGlow
onready var sprite := $Pivot/sprite
# onready var material_shader = $Pivot.get_node("sprite").material

onready var area_2d_ranged_attack_for_mobile := $Area2DAttackRangeForMobile

var player_id = 0
var current_anim = ""
var prev_bombing = false
var prev_spell1_mobile = false # Made to avoid spamming spell in the same tick
var bomb_index = 0
var current_health = MAX_HEALTH

# Overiden by the ranged player class
func init(index_char):
	var file_path_character = CHARACTER_INDEX_TO_PATH[index_char]
	get_node("sprite").texture = load(file_path_character)


func _ready():
	stunned = false
	puppet_pos = position
	EventBus.connect("game_ended_on_server", self, "_on_game_ended_on_server")
	
	health_component.init_life_bar(MAX_HEALTH)

	# Shader part
	timer_glow.connect("timeout", self, "stop_glow") # When timer expired, stop glowing
	sprite.material = sprite.material.duplicate()

	# Ensure the camera follows the player with smoothing only if this is the network master
	if EventBus.is_in_network_mode():
		if is_network_master():
			var camera = Camera2D.new()
			camera.current = true
			camera.zoom = Vector2(1.5, 1.5)
			add_child(camera)

		# Add the joystick UI if the node is the master
		# var joystick_ui = load("res://joystick/UI_Joystick.tscn").instance()
		# get_tree().get_root().call_deferred("add_child", joystick_ui)

		# var ui = load("res://scenes/UI.tscn").instance()
		# add_child(ui)


# Function to get the mobile joystick inputs
func get_joystick_motion_from_inputs() -> Vector2:
	var motion = Vector2()
	var strength_left = Input.get_action_strength("move_left")
	var strength_right = Input.get_action_strength("move_right")
	var strength_up = Input.get_action_strength("move_up")
	var strength_down = Input.get_action_strength("move_down")

	motion += Vector2(-strength_left, 0)
	motion += Vector2(strength_right, 0)
	motion += Vector2(0, -strength_up)
	motion += Vector2(0,strength_down)
	return motion.normalized() # normalize the vector so the player doesn't move faster when moving diagonally

# Function to get the nearest position of the class (Enemy most of the time) (used for the mobile attack)
func get_position_nearest_class_in_the_area(class_to_identify):
	# check if there is an enemy in the area Area2DAttackRangeForMobile:
	var bodies = area_2d_ranged_attack_for_mobile.get_overlapping_bodies()
	print_debug("player.gd - get_nearest_enemy_in_the_area - bodies: ", bodies)
	for body in bodies:
		if body is class_to_identify:
			return body.position
	return null

# Function to handle the inputs of the player (master or locally)
func handle_inputs_master():
	# Action from user input
	var bombing = Input.is_action_pressed("set_bomb")
	var spell1_mobile = Input.is_action_pressed("spell_1_mobile")

	if current_health <= 0:
		return

	if Input.is_action_pressed("move_left"):
		motion += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		motion += Vector2(1, 0)
	if Input.is_action_pressed("move_up"):
		motion += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		motion += Vector2(0, 1)

	
	if Input.is_action_pressed("ui_is_using_joystick"): # if the joystick is used, we get the motion from the inputs from the strength of the inputs.
		print_debug("player.gd - _physics_process - joystick is used")
		motion = get_joystick_motion_from_inputs()
		direction = motion
	else: # Otherwise, the direction is the position of the mouse in the screen
		# Get the direction to the mouse (will determine the rotation of the player and the direction of the arrows)
		direction = global_position.direction_to(get_global_mouse_position())

	if stunned: # useful if we are handling stunning spells. - ignored for now
		bombing = false
		motion = Vector2()

	# Attacking part
	if (bombing and not prev_bombing) or (spell1_mobile and not prev_spell1_mobile):
		print_debug("player.gd - _physics_process - bombing")
		should_cast_spell_1 = true
		
		# Attacking with mobile - we are targeting the nearest enemy in the area - we also override the direction of the player
		if spell1_mobile and not prev_spell1_mobile: # We override the direction of the bomb if we are using the mobile button
			var position_enemy = get_position_nearest_class_in_the_area(Enemy)
			print_debug("player.gd - _physics_process - position_enemy: ", position_enemy)
			if position_enemy != null:
				direction = global_position.direction_to(position_enemy)
			else: # if we didn't find any enemy in the area, we just shoot in the direction of the player
				print_debug("player.gd - _physics_process - position_enemy is null, shooting in the same direction as the player")
				direction = Vector2(cos(_pivot.rotation), sin(_pivot.rotation))
				print_debug("player.gd - _physics_process - direction: ", direction)


	# Reset attacking
	prev_spell1_mobile = spell1_mobile
	prev_bombing = bombing		
	

	# Send the position to all the puppets players (all other non-master players)
	if EventBus.is_in_network_mode():
		rset("puppet_motion", motion)
		rset("puppet_pos", position)
		rset("puppet_direction", direction)



func handle_inputs_puppet():
	position = puppet_pos
	motion = puppet_motion
	direction = puppet_direction

func shoot_spell_1():
	if not should_cast_spell_1:
		return 
	bomb_name = String(get_name())
	if EventBus.is_in_network_mode():
		rpc("shoot", bomb_name, shoot_position.global_position, direction, get_tree().get_network_unique_id())
	else:
		shoot(bomb_name, shoot_position.global_position, direction, 0)
	should_cast_spell_1 = false # put back to false


func action_player():
	# ANIMATION PART
	var new_anim = "standing"
	if motion.y < 0:
		new_anim = "walk_up"
	elif motion.y > 0:
		new_anim = "walk_down"
	elif motion.x < 0:
		new_anim = "walk_left"
	elif motion.x > 0:
		new_anim = "walk_right"
	if stunned:
		new_anim = "stunned"
	if new_anim != current_anim:
		current_anim = new_anim
	# TODO: Remove animation for now
	# get_node("anim").play(current_anim)

	# MOVE THE PLAYER
	move_and_slide(motion * MOTION_SPEED)
	
	# ROTATION PART
	_pivot.rotation = direction.angle() # Make the player rotate according to the direction (mouse position of the master node)
	
	# CASTING SPELLS PART
	shoot_spell_1() # We are casting the spell after we rotate the player. This is to ensure that we are not casting the spell in the wrong direction


	if EventBus.is_in_network_mode():
		if not is_network_master():
			puppet_pos = position # To avoid jitter


# MAIN FUNCTION
func _physics_process(_delta):
	motion = Vector2() # Reseting to 0 at each frame
	direction = Vector2() # Reseting to 0 at each frame

	if not EventBus.is_in_network_mode():
		handle_inputs_master()
	else:
		if is_network_master():
			handle_inputs_master()
		else:
			handle_inputs_puppet()
	
	action_player()


# Use sync because it will be called everywhere, including locally
# Default shoot - will be overridden by the ranged player
remotesync func shoot(bomb_name, pos, _direction, by_who):
	var bomb = preload("res://scenes/bomb.tscn").instance()
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = pos
	bomb.from_player = by_who
	# No need to set network master to bomb, will be owned by server by default
	get_node("../..").add_child(bomb)


# puppetsync func stun(player_id, _damage):
# 	print("player.gd - stun - player_id: ", player_id, " - _damage: ", _damage)
# 	# stunned = true
# 	current_health -= _damage
# 	EventBus.emit_signal("modify_health", player_id, current_health)

# 	life_ui_bar.value = current_health

# 	# Delete current node if health is 0 or below (the player is dead)
# 	if current_health <= 0:
# 		queue_free()


remotesync func exploded(_damage, player_id):
	print("player.gd - exploded - player_id: ", player_id, " - _damage: ", _damage)
	current_health -= _damage


	if EventBus.is_in_network_mode(): # This is temporary as in local mode we cannot test yet score update / game over
		EventBus.emit_signal("modify_health", player_id, current_health)
	health_component.update_life_bar(current_health, _damage)

	# Shader part - glowing in red when taking damage
	sprite.material.set_shader_param("use_red_color", true)
	timer_glow.start()	
	
	# Delete current node if health is 0 or below (the player is dead)
	if current_health <= 0:
		print("player.gd - exploded - player_id: ", player_id, " - player is dead")
		EventBus.emit_signal("player_died", player_id)
		queue_free()
	# if stunned:
	# 	print("player.gd - stun - node is stunned, not stunning again")
	# 	return
	# Update the score locally
	# $"../../Score".rpc("modify_health", get_tree().get_network_unique_id(), current_health - 1)
	# var masterPeerId = get_tree().get_network_unique_id() # getting the peerId of the master so we can send that along, to update the UI accordingly
	# rpc("stun", masterPeerId, _damage) # Stun puppets and local as puppetsync is used (so basically everywhere)


func take_damage(_damage: int, _from_player_id: int) -> void:
	print("player.gd - take_damage(): ", _damage)
	if not EventBus.is_in_network_mode(): # If testing locally, just call the function
		exploded(_damage, _from_player_id)
		return
	if not get_tree().is_network_server(): # the network server will propagate the damage to all clients
		return
	print("player.gd - take_damage -This node is the network server, calling exploded everywhere", _damage)
	rpc("exploded", _damage, player_id) # Exploded has a master keyword, so it will only be received by the master.
	# _damage_animation_player.play("take_damage")

func stop_glow() -> void:
	sprite.material.set_shader_param("use_red_color", false)
	sprite.material.set_shader_param("use_green_color", false)

func set_player_name(new_name):
	get_node("label").set_text(new_name)

func set_player_id(id):
	player_id = id

# Delete the player object when the game is finished on the server side
remotesync func _on_game_ended_on_server():
	print("player.gd - _on_game_ended_on_server - Game ended on server - deleting player")
	queue_free()

