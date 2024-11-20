# Allows its owner to detect hits and take damage
class_name HurtBox, "HurtBox.svg"
extends Area2D


# func _init() -> void:
# 	# The hurtbox should detect hits but not deal them. This variable does that.
# 	monitorable = false
# 	# This turns off collision layer bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
# 	# collision_mask = 2


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")


func _on_area_entered(hitbox: Node) -> void:
	print_debug("HurtBox.gd - _on_area_entered - hitbox: ", hitbox)
	if hitbox == null or not hitbox is HitBox: # Do nothing if hitbox is null or not of type HitBox
		return
	# hitbox.attack_landed() # for debug
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage, hitbox.from_player_id)
		hitbox.attack_landed()
	if hitbox.should_disapear_on_hit:
		print(" HurtBox.gd - _on_area_entered - hitbox: ", hitbox, "- should_disapear_on_hit - ", hitbox.should_disapear_on_hit)
		hitbox.get_parent().queue_free()

