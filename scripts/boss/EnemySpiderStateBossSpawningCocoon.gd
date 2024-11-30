extends State
class_name EnemySpiderStateBossSpawningCocoon

var enemy : KinematicBody2D
var player: KinematicBody2D
var direction_player: Vector2
var number_of_cocoons_alive : int = 2

const INVINSIBLE_SHADER_MATERIAL = preload("res://shaders/InvinsibleShader.tres")
const RED_AND_GREEN_SHADER_MATERIAL = preload("res://shaders/RedAndGreenGlowShader.tres")

signal attack_send

func Enter():
	print("EnemySpiderBossSpawningCocoon.gd - Enter - Entering EnemySpiderBossSpawningCocoon state") 


	enemy = get_parent().get_parent() # Getting the grand-parent of the script, i.e. the KinematicBody2D node to move it
	player = enemy.player

	number_of_cocoons_alive = 0
	# Spawning the cocoons
	for spawn_position in enemy.get_node("SpawnCocoonPositions").get_children():
		var enemy_to_spawn = preload("res://prefab/enemies/Spider_Cocoon.tscn").instance()
		enemy_to_spawn.get_node("StateMachine").initial_state = "enemyattackingdistance"
		enemy_to_spawn.player = player # Setting the player as the target of the cocoon
		enemy_to_spawn.set_name("Cocoon_spawned_1")
		enemy_to_spawn.global_position = spawn_position.global_position
		get_node("..").add_child(enemy_to_spawn)
		enemy_to_spawn.connect("enemy_died", self, "_on_child_enemy_died")
		number_of_cocoons_alive += 1

	# Load the shader material
	enemy.get_node("Sprite").material = INVINSIBLE_SHADER_MATERIAL
	
	# EventBus.connect("player_died", self, "player_died")
# func Update(delta: float):

func Exit():
	# Load back the shader material to take damage back
	enemy.get_node("Sprite").material = RED_AND_GREEN_SHADER_MATERIAL

# func flip_sprite_if_necessary():
# 	if not enemy.should_flip_sprite: # do nothing if the enemy should not flip the sprite
# 		return
# 	if direction_player.x < 0:
# 		enemy.flip_sprite(true)
# 		enemy.get_node("Sprite").flip_h = true
# 	else:
# 		enemy.flip_sprite(false)
# 		enemy.get_node("Sprite").flip_h = false

func Update(_delta: float):
	pass
	# if not enemy.is_attack_on_cooldown:
	# 	if not EventBus.is_in_network_mode():
	# 		attack()
	# 	elif is_network_master():
	# 		rpc("attack")
	# 	return

func Physics_Update(_delta: float):
	pass
	# if not enemy or not player or not is_instance_valid(enemy) or not is_instance_valid(player):
	# 	return
	# direction_player = (player.global_position - enemy.global_position).normalized()
	
	# flip_sprite_if_necessary()

		# enemy.look_at(enemy.position + move_direction)
		# enemy.play("walk")

remotesync func attack():
	print_debug("EnemyAttackingDistance.gd - attack - attacking")
	# var bomb = preload("res://weapons/Arrow.tscn").instance()
	# bomb.direction = direction_player
	# # No need to set network master to bomb, will be owned by server by default
	# get_node("../..").add_child(bomb)
	emit_signal("attack_send", direction_player, player.global_position)
		# attack_landed()

func player_died(player_id):
	if player_id == player.player_id: # if the player we are attacking dies, goes to Idle State
		emit_signal("transitioned", self, "EnemyIdle")

func _on_child_enemy_died():
	number_of_cocoons_alive -= 1

	if number_of_cocoons_alive <= 0:
		emit_signal("transitioned", self, "EnemyAttackingDistance")
