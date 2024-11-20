class_name Lava

extends Projectile

onready var timer_transform_in_lava := $TimerTransformInLava
onready var sprite_lava := $SpriteLava

func _ready():
    # Set values of hitbox for projectiles:
    hitbox.damage = 1
    hitbox.should_disapear_on_hit = false
    hitbox.from_player_id = from_player_id
    timer_transform_in_lava.connect("timeout", self, "transform_in_lava")

# The lava should not be moving at each frame
func _physics_process(_delta: float) -> void:
    pass

func _on_impact(_body: Node) -> void:
    print("Lava.gd - _on_impact - _body: ", _body)
    # not used for now - should be removed if not used - keeping it here just in case
    # queue_free()


func transform_in_lava():
    # Apply the ShaderMaterial to the sprite
    sprite.visible = false
    sprite_lava.visible = true

    # Activate the hitbox
    hitbox.get_node("CollisionShape2D").disabled = false
