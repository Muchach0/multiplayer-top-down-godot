extends Node2D

var players = null
var global_score = 0 # Variable to store the global score
var number_of_enemies = 0 # Variable to store the number of enemies in the scene

onready var enemy_list := $Enemies if has_node("Enemies") else null

# Called when the node enters the scene tree for the first time.
func _ready():
	players = gamestate.players
	
	# Connecting signal from the EventBus to increase the global score
	# TODO: THis should be handled by the UI component, and not the world component.
	EventBus.connect("update_score", self, "increase_score")
	EventBus.connect("player_died", self, "player_died")
	EventBus.connect("one_enemy_die", self, "one_enemy_die")

	init_world()


# Get spawn positions for each player
func get_spawn_points(players):
	var spawn_points = {}
	# spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 0
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	return spawn_points


# Initialize the world for every peer
func init_world():
	var spawn_points = get_spawn_points(players)
	# var player_scene = load("res://scenes/player.tscn")

	for p_id in spawn_points:
		var spawn_pos = get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var char_index = players[p_id]["char_index"]
		players[p_id]["is_alive"] = true # player is alive, useful for tracking end of the game
		var player_scene = null
		# Instance the player scene based on the character index
		if char_index == 3:
			player_scene = load("res://prefab/players/Player_bow.tscn")
		elif char_index == 4:
			player_scene = load("res://prefab/players/Player_ranged.tscn")
		else:
			player_scene = load("res://prefab/players/Player_bow.tscn")
		var player = player_scene.instance()
		# Instantiate the character sprite chosen
		player.init(players[p_id]["char_index"])

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position=spawn_pos
		player.set_network_master(p_id) # set unique id as master.

		player.set_player_name(players[p_id]["name"]) # set player's name
		player.set_player_id(p_id) # set player's id

		get_node("Players").add_child(player)

	# var ui = load("res://scenes/UI.tscn").instance()
	# add_child(ui)

	# Set up score.
	for pn in players:
		$UI.get_node("Score_ui").add_player(pn, players[pn]["name"])
		# get_node("Score_ui").add_player(pn, players[pn]["name"])
	
	# Update UI with score
	update_ui_with_score()

	# Count the number of enemies in the scene: 
	number_of_enemies = len(get_node("Enemies").get_children())
	print("world.gd - init_world - Number of enemies: ", number_of_enemies)


func update_ui_with_score():
	print("Global score: ", global_score)
	$UI.get_node("GlobalScoreLabel").set_text("Global Score: " + str(global_score))

func increase_score(score_to_add, player_id):
	global_score += score_to_add
	update_ui_with_score()
	
	print("world.gd - increase_score - score_to_add: ", score_to_add, " - player_id: ", player_id)
	$UI.get_node("Score_ui").increase_score(player_id, score_to_add)
	# get_node("Score_ui").increase_score(player_id, score)

func player_died(player_id):
	print("world.gd - player_died - player_id: ", player_id)
	if not EventBus.is_in_network_mode():
		return
	# update the dict of players to keep track of the player that died
	players[player_id]["is_alive"] = false

	# check if there is still some players alive
	var still_player_alive = false
	print("world.gd - player_died - players: ", players)
	for p in players:
		if players[p]["is_alive"]:
			still_player_alive = true
			print("world.gd - p - is still alive: ", p)
			break
	if not still_player_alive:
		# all players are dead, game over
		print("world.gd - player_died - Game Over - No player alive")
		EventBus.emit_signal("no_player_alive")
		gamestate.end_game_on_server()

	# check if there is still some players


# Function called by signal 'one_enemy_die' everytime an enemy dies
func one_enemy_die():
	if enemy_list == null: # do nothing if the enemy_list is null
		return
	
	if len(enemy_list.get_children()) > 0: # do nothing if still some enemies alive
		return
	
	# all enemies are dead, game over
	print_debug("world.gd - one_enemy_die - Game Over - All enemies are dead")
	EventBus.emit_signal("all_enemies_dead")
	gamestate.end_game_on_server()
