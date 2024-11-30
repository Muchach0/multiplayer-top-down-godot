extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    # Play the "rise" animation when the scene is added to the tree
    $AnimationPlayer.play("appear")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
