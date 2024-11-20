extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var timer_spawner := $TimerSpawner
var enemy_scene = null
# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_scene = load("res://scenes/Enemy.tscn")
	timer_spawner.connect("timeout", self, "spawn_ennemy")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_ennemy() -> void:
	print_debug("EnemySpawner.gd - spawn_ennemy() - spanning an ennemy")
	var enemy = enemy_scene.instance()
	enemy.position = position
	# add_child(enemy)
	# No need to set network master to eme,y, will be owned by server by default
	get_node("..").add_child(enemy)
