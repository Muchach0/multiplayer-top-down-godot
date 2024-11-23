extends Node2D
class_name HealthComponent

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var life_ui_bar = $LifeUIBar
onready var damage_spawning_point = $DamageSpawningPoint

func init_life_bar(health):
	life_ui_bar.max_value = health
	life_ui_bar.value = health

func update_life_bar(health, damage_taken):
	life_ui_bar.value = health
	# Create a DamageLabel
	var damage_label := preload("res://prefab/components/DamageLabel.tscn").instance()
	damage_label.global_position = damage_spawning_point.global_position
	damage_label.set_damage(damage_taken)
	add_child(damage_label)

func _ready():
	pass # Replace with function body.


