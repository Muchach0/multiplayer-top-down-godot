class_name EnemySpiderBoss
extends Enemy

# Attacking part
# onready var hitbox := $HitBox
# onready var hitbox_collision_shape := $HitBox/CollisionShape2D
# onready var hurtbox_collision_shape := $HurtBox/CollisionShape2D

var is_spell2_attack_on_cooldown = false
onready var timer_attack_cooldown_spell_2 := $TimerSpawnCocoon

#================ ATTACK PART ================
func attack_landed():
	print_debug("Enemy_spider_boss.gd - attack_landed - setting up the cooldown")
	is_attack_on_cooldown = true
	# hitbox_collision_shape.set_deferred("disabled", true) # Disabling the hitbox when we landed an attack
	# hitbox_collision_shape.disabled = true
	timer_attack_cooldown.start()



func attack_spell_2_spawn_cocoon(_player_direction: Vector2) -> void:
	print_debug("Enemy_spider_boss.gd - attack_spell_1 - attacking with spell 1")
	# emit_signal("transitioned", self, "EnemySpiderStateBossSpawningCocoon")

	is_spell2_attack_on_cooldown = true
	timer_attack_cooldown_spell_2.start()

	$StateMachine.current_state.emit_signal("transitioned", $StateMachine.current_state, "EnemySpiderStateBossSpawningCocoon")


	# animation_player_action_enemy.stop(true)
	# animation_player_action_enemy.play("Spell1")
	# var bomb = preload("res://prefab/weapons/Arrow_enemy.tscn").instance()
	# bomb.position = self.global_position
	# bomb.direction = player_direction
	# # No need to set network master to
	# get_node("../..").add_child(bomb)

# Instantiating the lava pit at the player position
func attack_spell_1_spike(position_player: Vector2) -> void:
	print_debug("Enemy_spider_boss.gd - attack - attacking with spike spell")
	animation_player_action_enemy.stop(true)
	# animation_player_action_enemy.play("Spell1") # Adjust here animation

	# Instiantiating a spike at player position
	var spike = preload("res://prefab/enemies/boss/Spider_spike.tscn").instance()
	spike.global_position = position_player

	get_node("..").add_child(spike)
	# attack_landed()


# Signal sent from the State EnemyAttackingDistance: 'attack_send'
# Instantiating the projectile in players direction
func _on_EnemyAttackingDistance_attack_send(_player_direction: Vector2, position_player: Vector2) -> void:
	print_debug("Enemy_spider_boss.gd - attack - attacking")
	# attack_spell_1(player_direction)
	if is_spell2_attack_on_cooldown:
		attack_spell_1_spike(position_player)
	else:
		attack_spell_2_spawn_cocoon(position_player)
	attack_landed()




func reset_cooldown(): # Reseting attack cooldown when the timer is finished
	print_debug("Enemy_spider_boss.gd- reset_cooldown - reseting cooldown")
	is_attack_on_cooldown = false

func _on_TimerCocoon_timeout():
	is_spell2_attack_on_cooldown = false

# Function to sync damage to all the peers (from the master of the node).
# The Enemy is supposed to always be owned by the server! (so server == master of the node).
# This is in 'remotesync' mode because we want also to use that function on the master.
remotesync func sync_damage(damage: int, from_player_id:int, health_from_server: int) -> void:
	print("Enemy.gd - sync_damage - damage: ", damage, " - from_player_id: ", from_player_id, " - health_from_server: ", health_from_server)
	health = health_from_server

	# If we are in the state of spawning cocoon, we don't take any damage
	if get_node("StateMachine").current_state is EnemySpiderStateBossSpawningCocoon:
		damage = 0
	else:
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
