# Detected by HitBox
class_name HitBox, "HitBox.svg"
extends Area2D

export var damage := 1 # default damage value
export var should_disapear_on_hit := false # default value - should be true for projectiles, but false for melee attacks
var from_player_id := 0

onready var collision_shape := $CollisionShape2D

signal attack_landed

# func _init() -> void:
# 	collision_mask = 2
# 	# This turns off collision mask bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
# 	collision_layer = 2

# Function call from the Hutrbox to the hitbox when an attack landed
func attack_landed():
	emit_signal("attack_landed") # emitting signal for the parent to handle it


# func set_disabled(is_disabled: bool) -> void:
# 	collision_shape.set_deferred("disabled", is_disabled)
