extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func button_kill_all_pressed():
	print_debug("dev_scripts.gd - button_kill_all_pressed() - Button kill all pressed")
	print_debug("dev_scripts.gd - button_kill_all_pressed() - Checking if a multiplayer game: ", EventBus.is_in_network_mode())
	
	if has_node("/root/World") == false: # Checking if a game is in progress
		print_debug("dev_scripts.gd - button_kill_all_pressed() - World node not found - not in a game")
		return
	
	var world = get_node("/root/World")

	# Go through all children of the world node and remove them
	for child in world.get_children():
		# Test if the child is an ennemy
		if child is Enemy:
			print_debug("dev_scripts.gd - button_kill_all_pressed() - inflict 9999 damage to the enemy: ", child)
			if EventBus.is_in_network_mode():
				child.rpc("take_damage", 9999, get_tree().get_network_unique_id())
			else:
				child.take_damage(9999, 0)
		# Check the name of the child node 
		elif child.get_name() == "Enemies": # In most of the scenes, the ennemies are part of a 2D node called "Enemies"
			for enemies_child in child.get_children():
				if enemies_child is Enemy:
					print_debug("dev_scripts.gd - button_kill_all_pressed() - inflict 9999 damage to the enemy:", enemies_child)
					if EventBus.is_in_network_mode():
						enemies_child.rpc("take_damage", 9999, get_tree().get_network_unique_id())
					else:
						enemies_child.take_damage(9999, 0)


func _on_Button_kill_one_player_pressed():
	print_debug("dev_scripts.gd - _on_Button_kill_one_player_pressed() - Checking if a multiplayer game: ", EventBus.is_in_network_mode())
	if has_node("/root/World") == false: # Checking if a game is in progress
		print_debug("dev_scripts.gd - _on_Button_kill_one_player_pressed() - World node not found - not in a game")
		return
	var world = get_node("/root/World")
	for child in world.get_children():
		if child is MyPlayer:
			print_debug("dev_scripts.gd - _on_Button_kill_one_player_pressed() - inflict 9999 damage to the player: ", child)
			if EventBus.is_in_network_mode():
				child.rpc("take_damage", 9999, get_tree().get_network_unique_id())
			else:
				# child.queue_free()
				child.take_damage(9999, 0)
				
			return
