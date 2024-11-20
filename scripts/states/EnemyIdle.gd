extends State
class_name EnemyIdle

var enemy : KinematicBody2D


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		print_debug("EnemyIdle.gd - _on_Area2D_body_entered - Player entered the area")
		enemy.player = body

		# Handle different types of ennemies State
		if enemy is EnemyWizard:
			emit_signal("transitioned", self, "EnemyAttackingDistance")
		else:
			emit_signal("transitioned", self, "EnemyFollowing")

func Enter():
	enemy = get_parent().get_parent() # Getting the grand-parent of the script, i.e. the KinematicBody2D node to move it
	# Connecting the enemy aggro area to the function _on_Area2D_body_entered
	# i.e. this is to be able to detect enemy entering the aggro area

	# Check if enemy.get_node("Area2D") is already connected:
	if enemy.get_node("Area2D").is_connected("body_entered", self, "_on_Area2D_body_entered") == false:
		enemy.get_node("Area2D").connect("body_entered", self, "_on_Area2D_body_entered")
