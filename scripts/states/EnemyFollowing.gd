extends State
class_name EnemyFollowing

var enemy : KinematicBody2D
var player: KinematicBody2D
export var move_speed := 100.0

var direction = Vector2() # Direction that is taking the enemy to the player

puppet var puppet_position = Vector2()
puppet var puppet_direction = Vector2()



func Enter():
	print("EnemyFollowing.gd - Enter - ENtering EnemyFollowing state") 
	enemy = get_parent().get_parent() # Getting the grand-parent of the script, i.e. the KinematicBody2D node to move it
	player = enemy.player
	EventBus.connect("player_died", self, "player_died")

	# Test if the animation player of the nemy has the walk animation
	if enemy.get_node("AnimationPlayerActionEnemy").has_animation("walk"):
		enemy.get_node("AnimationPlayerActionEnemy").play("walk")
# func Update(delta: float):

func flip_sprite_if_necessary(direction):
	# Part to handle the sprite flip (set to false by default)
	if not enemy.should_flip_sprite:
		return
	if direction.x < 0:
		enemy.get_node("Sprite").flip_h = true
	else:
		enemy.get_node("Sprite").flip_h = false


func Physics_Update(_delta: float):
	if not enemy or not player:
		return

	if not EventBus.is_in_network_mode() or is_network_master(): # If in local mode or master, move the ennemy as regular
		# print_debug("EnemyFollowing.gd - Physics_Update - Not in network mode or is network master")
		direction = player.global_position - enemy.global_position
		if EventBus.is_in_network_mode(): # if in network mode, the master sync to puppets
			rset_unreliable("puppet_position", enemy.position)
			rset_unreliable("puppet_direction", direction)

	# In multiplayer mode, the puppet moves the enemy based on the info from from the master
	if EventBus.is_in_network_mode() and not is_network_master():
		enemy.position = puppet_position
		direction = puppet_direction

	if enemy.should_be_able_to_move: # Moving the ennemy if the flag is set to true
		enemy.move_and_slide(direction.normalized() * move_speed)

	if EventBus.is_in_network_mode() and not is_network_master():
		puppet_position = enemy.position # to avoid jitter

	# In all case flip the sprite if necessary	
	flip_sprite_if_necessary(direction)


	# Play the walk animation
	# if direction.length() > 0:
	# 	enemy.look_at(enemy.position + direction)
	# 	enemy.play("walk")

		# enemy.look_at(enemy.position + move_direction)
		# enemy.play("walk")
func player_died(player_id):
	if player_id == player.player_id: # if the player we are attacking dies, goes to Idle State
		emit_signal("transitioned", self, "EnemyIdle")
