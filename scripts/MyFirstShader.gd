extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var glowing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	# material.set_shader_param("red", red_value)

 
# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	if glowing:
# 		glow_strength = (glow_strength == 0.0) ? 1.0 : 0.0
# 		material.set_shader_param("glow_strength", glow_strength)

func _on_Timer_timeout():
	glowing = !glowing
	material.set_shader_param("use_red_color", glowing)
	material.set_shader_param("use_green_color", glowing)

