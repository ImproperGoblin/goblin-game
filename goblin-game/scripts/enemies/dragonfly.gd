extends Node2D

const STUN_TIMER = 4
const ANIMATION = {
	"STUNNED": "stunned",
	"FLYING": "flying"
}

@onready var sprite: AnimatedSprite2D = $DragonflyAnimation/AnimatedSprite2D
@onready var dragonfly_animation: AnimatableBody2D = $DragonflyAnimation
@onready var path: PathFollow2D = $Dragonfly/PathFollow2D

var is_stunned = false;
var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.animation = ANIMATION.FLYING
	
func _process(delta: float) -> void:
	if(is_stunned):
		path.progress += 0
	else:
		path.progress += speed * delta

func _on_dragonfly_animation_flashbang() -> void:
	sprite.animation = ANIMATION.STUNNED
	is_stunned = true
	await get_tree().create_timer(STUN_TIMER).timeout
	sprite.animation = ANIMATION.FLYING
	is_stunned = false
