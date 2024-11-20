class_name Projectile
extends Node2D

export var speed := 1000.0
export var lifetime := 3.0

var direction := Vector2.ZERO
var from_player_id := 0 # id of the player creating the projectiles (useful to calculate the score per player)

onready var timer := $Timer
onready var hitbox := $HitBox
onready var sprite := $Sprite
onready var impact_detector := $ImpactDetector


func _ready():
	set_as_toplevel(true)
	look_at(position + direction)
	timer.connect("timeout", self, "queue_free")
	timer.start(lifetime)
	impact_detector.connect("body_entered", self, "_on_impact")

	# Set values of hitbox for projectiles:
	hitbox.damage = 1
	hitbox.should_disapear_on_hit = true
	hitbox.from_player_id = from_player_id


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_impact(_body: Node) -> void:
	print("Projectile.gd - _on_impact - _body: ", _body)
	# not used for now - should be removed if not used - keeping it here just in case
	# queue_free()
