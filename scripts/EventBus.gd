# Event bus to communicate between nodes
extends Node

signal update_score
signal modify_health
signal player_died
signal no_player_alive
signal one_enemy_die
signal all_enemies_dead
signal game_ended_on_server

# Function to know if we are running in a network mode or not.
func is_in_network_mode() -> bool:
	if get_tree().network_peer:
		return true
	return false