extends Enemy
class_name EnemySpawner

# Class to spawn enemies


# Override the _ready function from the Enemy script
func _ready():
	pass


remotesync func spawn_ennemy():
	print_debug("EnemySpawner.gd - spawn_ennemy() - spanning an ennemy")
	var enemy = preload("res://prefab/enemies/Spider_1.tscn").instance()
	enemy.set_name("Spider_spawned_1")
	enemy.position = position
	get_node("..").add_child(enemy)


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
