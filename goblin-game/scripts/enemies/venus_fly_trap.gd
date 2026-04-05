extends Node2D

const SNAP_TIME: float = 0.8


var player_node: Node = null
var increase_snap_timer: bool = false
var snap_timer: float = 0.0

var is_snap_animating: bool = false
var is_unfurling: bool = false

const ANIMATION = {
	"STATIC": "static",
	"AGITATED": "agitated",
	"SNAP": "snap_shut",
	"UNFURL": "unfurl"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles2D.emitting = false
	$AnimatedSprite2D.animation = ANIMATION.STATIC

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if increase_snap_timer:
		snap_timer += delta
		
	if snap_timer >= SNAP_TIME:
		if not is_snap_animating and not is_unfurling:
			_snap()

func _snap():
	is_snap_animating = true
	is_unfurling = false
	increase_snap_timer = false
	snap_timer = 0.0
	
	$GPUParticles2D.emitting = false
	
	$AnimatedSprite2D.animation = ANIMATION.SNAP
	$AnimatedSprite2D.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_node = body
		snap_timer = 0
		increase_snap_timer = true
		$GPUParticles2D.emitting = true
		
		if not is_snap_animating and not is_unfurling:
			$AnimatedSprite2D.animation = ANIMATION.AGITATED
			$AnimatedSprite2D.play()


func _on_area_2d_body_exited(body: Node2D) -> void:	
	if body.name == "Player":
		player_node = null

func _on_animated_sprite_2d_animation_finished() -> void:
	match $AnimatedSprite2D.animation:
		'snap_shut':
			if player_node:
				player_node._bounce_away_from_enemy(self)
				player_node._reduce_hp(1)
				player_node = null
			
			is_snap_animating = false
			is_unfurling = true

			$AnimatedSprite2D.animation = ANIMATION.UNFURL
			$AnimatedSprite2D.play()
			
		'unfurl':
			is_snap_animating = false
			is_unfurling = false
			
			if player_node:
				snap_timer = 0
				increase_snap_timer = true
				$AnimatedSprite2D.animation = ANIMATION.AGITATED
			else:
				$AnimatedSprite2D.animation = ANIMATION.STATIC
