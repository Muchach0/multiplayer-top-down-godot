class_name EnemyWizard
extends Enemy

# Attacking part
# onready var hitbox := $HitBox
# onready var hitbox_collision_shape := $HitBox/CollisionShape2D
# onready var hurtbox_collision_shape := $HurtBox/CollisionShape2D

var is_spell2_attack_on_cooldown = false
onready var timer_attack_cooldown_spell_2 := $TimerLava
export var nb_of_lavas_to_spawn = 9

#================ ATTACK PART ================
func attack_landed():
	print_debug("Enemy_wizard.gd - attack_landed - setting up the cooldown")
	is_attack_on_cooldown = true
	# hitbox_collision_shape.set_deferred("disabled", true) # Disabling the hitbox when we landed an attack
	# hitbox_collision_shape.disabled = true
	timer_attack_cooldown.start()



func attack_spell_1(player_direction: Vector2) -> void:
	print_debug("Enemy_wizard.gd - attack_spell_1 - attacking with spell 1")
	animation_player_action_enemy.stop(true)
	animation_player_action_enemy.play("Spell1")
	var bomb = preload("res://weapons/Arrow_enemy.tscn").instance()
	bomb.position = self.global_position
	bomb.direction = player_direction
	# No need to set network master to
	get_node("../..").add_child(bomb)

# Instantiating the lava pit at the player position
func attack_spell_2_lava(position_player: Vector2) -> void:
	print_debug("Enemy_wizard.gd - attack - attacking with lava spell")
	animation_player_action_enemy.stop(true)
	animation_player_action_enemy.play("Spell1") # Adjust here animation

	# Instiantiating the lava pit at the player position - nb of 7 lava pits
	var direction = (position_player - global_position).normalized()
	var spacing = 100  # Adjust the spacing between fireballs as needed

	for i in range(nb_of_lavas_to_spawn):
		var lava_pit = preload("res://scenes/ennemies/Fireball2.tscn").instance()
		lava_pit.position = global_position + direction * spacing * (i+1)
		# No need to set network master to
		get_node("../..").add_child(lava_pit)

	is_spell2_attack_on_cooldown = true
	timer_attack_cooldown_spell_2.start()


	# var lava_pit = preload("res://scenes/ennemies/Fireball2.tscn").instance()
	# lava_pit.position = player_position
	# No need to set network master to
	# get_node("../..").add_child(lava_pit)
	# attack_landed()


# Signal sent from the State EnemyAttackingDistance: 'attack_send'
# Instantiating the projectile in players direction
func _on_EnemyAttackingDistance_attack_send(player_direction: Vector2, position_player: Vector2) -> void:
	print_debug("Enemy_wizard.gd - attack - attacking")
	if is_spell2_attack_on_cooldown:
		attack_spell_1(player_direction)
	else:
		attack_spell_2_lava(position_player)
	attack_landed()




func reset_cooldown(): # Reseting attack cooldown when the timer is finished
	print_debug("Enemy_wizard.gd - reset_cooldown - reseting cooldown")
	is_attack_on_cooldown = false

func _on_TimerLava_timeout():
	is_spell2_attack_on_cooldown = false
