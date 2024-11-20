extends HBoxContainer


var player_labels = {}
const MAX_HEALTH = 5

func _ready():
	#  $"../Winner".hide()
	set_process(true)
	EventBus.connect("modify_health", self, "modify_health_in_score")
	EventBus.connect("no_player_alive", self, "no_player_alive")
	EventBus.connect("all_enemies_dead", self, "all_enemies_dead")

# func _process(_delta):
	# var rocks_left = $"../Rocks".get_child_count()
	# if rocks_left == 0:
	# 	var winner_name = ""
	# 	var winner_score = 0
	# 	for p in player_labels:
	# 		if player_labels[p].score > winner_score:
	# 			winner_score = player_labels[p].score
	# 			winner_name = player_labels[p].name

	# 	$"../Winner".set_text("THE WINNER IS:\n" + winner_name)
	# 	$"../Winner".show()
	# 	gamestate.end_game_on_server()

	# var number_of_player_alive_and_name_last_player = get_number_of_player_alive_and_name_last_player()
	# if number_of_player_alive_and_name_last_player["nb_player_alive"] == 1 && player_labels.size() != 1:
	# 	$"../Winner".set_text("THE WINNER IS:\n" + number_of_player_alive_and_name_last_player["last_alive_player_name"])
	# 	$"../Winner".show()
	# 	gamestate.end_game_on_server()
	# if number_of_player_alive_and_name_last_player["nb_player_alive"] == 0:
	# 	$"../Winner".set_text("THERE IS NO WINNER IN THIS GAME")
	# 	$"../Winner".show()
	# 	gamestate.end_game_on_server()

func get_number_of_player_alive_and_name_last_player():
	var number_of_player_alive = 0
	var player_name_alive = ""
	for player in player_labels:
		if player_labels[player].health > 0:
			number_of_player_alive += 1
			player_name_alive = player_labels[player].name
	return {"nb_player_alive": number_of_player_alive, "last_alive_player_name": player_name_alive}

# Return the label to display.
func get_score_label_for_player(player_id):
	var player = player_labels[player_id]
	return player.name + "\n score:" + str(player.score) + "\n health:" + str(player.health)

func refresh_score_and_health_for_player(player_id):
	var pl = player_labels[player_id]
	pl.label.set_text(get_score_label_for_player(player_id))

remotesync func increase_score(for_who, score_to_add):
	print("score.gd - increase_score - for_who, ", for_who, " - score_to_add: ", score_to_add)
	if not for_who in player_labels:
		print("score.gd - increase_score - player not in player_labels")
		return
	assert(for_who in player_labels)
	var pl = player_labels[for_who]
	pl.score += 1
	refresh_score_and_health_for_player(for_who)

func modify_health_in_score(player_id, new_health):
	print("player_id: " + str(player_id))
	print("player_labels: " + str(player_labels))
	assert(player_id in player_labels)
	var pl = player_labels[player_id]
	pl.health = new_health
	refresh_score_and_health_for_player(player_id)


func add_player(id, new_player_name):
	print("score.gd - add_player() - adding player id ", id, " - player_name: ", new_player_name)
	var l = Label.new()
	l.set_align(Label.ALIGN_CENTER)
	l.set_h_size_flags(SIZE_EXPAND_FILL)
	var font = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://assets/montserrat.otf"))
	l.add_font_override("font", font)
	add_child(l)

	player_labels[id] = { "name": new_player_name, "label": l, "score": 0, "health": MAX_HEALTH }
	print("score.gd - add_player() - player_labels: " + str(player_labels))
	refresh_score_and_health_for_player(id)

func no_player_alive():
	print("score.gd - no_player_alive() - No player alive, showing the UI")
	$"../Winner".set_text("THERE IS NO WINNER IN THIS GAME")
	$"../Winner".show()
	

func all_enemies_dead():
	print("score.gd - all_enemies_dead() - All enemies are dead, showing the UI")
	var player_with_highest_score = ""
	var highest_score = 0
	for player in player_labels:
		if player_labels[player].score > highest_score:
			highest_score = player_labels[player].score
			player_with_highest_score = player_labels[player].name
	$"../Winner".set_text("ALL ENEMIES DEAD - THE WINNER IS:\n" + player_with_highest_score)
	$"../Winner".show()

func _on_exit_game_pressed():
	print_debug("score.gd - _on_exit_game_pressed() - Exit game pressed")
	gamestate.end_game()
