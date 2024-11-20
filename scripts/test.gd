extends SceneTree

var player_labels = {}


func get_number_of_player_alive_and_name_last_player():
	var number_of_player_alive = 0
	var player_name_alive = ""
	for player in player_labels:
		if player_labels[player].health > 0:
			number_of_player_alive += 1
			player_name_alive = player_labels[player].name
	return {"nb_player_alive": number_of_player_alive, "last_alive_player_name": player_name_alive}


func test_player_alive():
    print("====== test.gd - test_player_alive - starting ======")
    var players = {590570544:{char_index=3, name="test2", ready=true}, 2101295025:{char_index=3, name="test1", ready=true}}
    players[2101295025]["is_alive"] = true
    players[590570544]["is_alive"] = false
    var still_player_alive = false
    for p in players:
        print("p: ", p)
        if players[p]["is_alive"]:
            still_player_alive = true
            print("still_player_alive 1: ", still_player_alive)
            break
    print("still_player_alive 2: ", still_player_alive)
    if not still_player_alive:
        print("no player alive")
    print("====== test.gd - test_player_alive - ending ======")

func test_vector_null():
    print("====== test.gd - test_vector_null - starting ======")

    var vector = Vector2(0, 0)
    if vector != null:
        print("vector is not null")


    print("====== test.gd - test_vector_null - ending ======")

func _init():
    player_labels[1] = { name = "riri", label = "label", score = 0, health = 0 }
    player_labels[2] = { name = "bibi", label = "label", score = 0, health = 0 }
    print(player_labels.size())
    for key in player_labels:
        print(key)
    print(get_number_of_player_alive_and_name_last_player())
    test_player_alive()
    test_vector_null()
    quit()