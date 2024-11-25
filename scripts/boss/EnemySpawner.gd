extends Enemy
class_name EnemySpawner


onready var spawn_points := $SpawnPoints if has_node("SpawnPoints") else null

# Class to spawn enemies


# Override the _ready function from the Enemy script
func _ready():
	pass

func get_closer_spawn_point(position_player: Vector2) -> Vector2:
	if spawn_points == null:
		print_debug("EnemySpawner.gd - get_closer_spawn_point - no spawn points")
		return position
	var closest_spawn_point = Vector2()
	var closest_distance = INF # Infinity - very large number for initialization
	for spawn_point in spawn_points.get_children():
		var distance = position_player.distance_to(spawn_point.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_spawn_point = spawn_point.global_position
	return closest_spawn_point

remotesync func spawn_ennemy():
	print_debug("EnemySpawner.gd - spawn_ennemy() - spawning an ennemy")
	var enemy_to_spawn = preload("res://prefab/enemies/Spider_1.tscn").instance()
	enemy_to_spawn.set_name("Spider_spawned_1")
	enemy_to_spawn.global_position = get_closer_spawn_point(player.global_position)
	get_node("..").add_child(enemy_to_spawn)


#================ ATTACK PART ================
func attack_landed():
	print_debug("EnemySpawner.gd - attack_landed - setting up the cooldown")
	is_attack_on_cooldown = true
	timer_attack_cooldown.start()

# Signal sent from the State EnemyAttackingDistance: 'attack_send'
func _on_EnemyAttackingDistance_attack_send(_player_direction: Vector2, _position_player: Vector2) -> void:
	print_debug("EnemySpawner.gd - attack - attacking")
	
	if EventBus.is_in_network_mode():
		if is_network_master():
			rpc("spawn_ennemy") # Spawning the enemy from the server
	else:
		spawn_ennemy()
	
	attack_landed()


func reset_cooldown(): # Reseting attack cooldown when the timer is finished
	print_debug("EnemySpawner.gd - reset_cooldown - reseting cooldown")
	is_attack_on_cooldown = false
