extends MyPlayer

# const FireballScene := preload("res://weapons/Fireball.tscn")
# const ArrowScene := preload("res://weapons/Arrow.tscn")

# func _physics_process(_delta: float) -> void:
# 	look_at(get_global_mouse_position())

func init(_index_char):
	# get_node("sprite").texture = load("res://weapons/wand_fire.png")
	print("Player_ranged init")

# func _unhandled_input(event: InputEvent) -> void:
# 	if event.is_action_pressed("left_click"):
# 		shoot(ArrowScene)
# 	elif event.is_action_pressed("right_click"):
# 		shoot(FireballScene)



# func shoot_secondary()

# Use sync because it will be called everywhere, including locally
remotesync func shoot(bomb_name, pos, direction, by_who):
	var bomb = preload("res://weapons/Arrow.tscn").instance()
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = pos
	bomb.from_player_id = by_who
	bomb.direction = direction
	# No need to set network master to bomb, will be owned by server by default
	get_node("../..").add_child(bomb)
