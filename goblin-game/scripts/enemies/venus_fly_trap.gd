extends Node2D

const SNAP_TIME: float = 0.8
const SHAKE_AMOUNT: float = 3.0
const SHAKE_SPEED: float = 40.0

var default_pos: Vector2

var player_node: Node = null
var increase_snap_timer: bool = false
var snap_timer: float = 0.0

var is_snap_animating: bool = false
var is_unfurling: bool = false
var is_agitating: bool = false

const ANIMATION = {
	"STATIC": "static",
	"AGITATED": "agitated",
	"SNAP": "snap_shut",
	"UNFURL": "unfurl"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_pos = global_position
	
	$GPUParticles2D.emitting = false
	$AnimatedSprite2D.animation = ANIMATION.STATIC

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_node and player_node._is_on_or_above_node('VenusFlyTrap') and not is_agitating:
		_agitate()
	
	if increase_snap_timer:
		global_position.x = default_pos.x + sin(snap_timer * SHAKE_SPEED) * SHAKE_AMOUNT
		snap_timer += delta
		
	if snap_timer >= SNAP_TIME:
		if not is_snap_animating and not is_unfurling:
			_snap()

func _agitate():
	is_agitating = true
	snap_timer = 0
	increase_snap_timer = true
	$GPUParticles2D.emitting = true
	
	if not is_snap_animating and not is_unfurling:
		$AnimatedSprite2D.animation = ANIMATION.AGITATED
		$AnimatedSprite2D.play()

func _snap():
	is_agitating = false
	is_snap_animating = true
	is_unfurling = false
	
	$AnimatedSprite2D.animation = ANIMATION.SNAP
	$AnimatedSprite2D.play()	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_node = body

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
				
			$StaticBody2D/CollisionShape2D.disabled = true
	
			is_snap_animating = false
			is_unfurling = true

			$AnimatedSprite2D.animation = ANIMATION.UNFURL
			$AnimatedSprite2D.play()
			
		'unfurl':
			is_snap_animating = false
			is_unfurling = false
			is_agitating = false

			$StaticBody2D/CollisionShape2D.disabled = false
			
			snap_timer = 0

			if player_node:
				increase_snap_timer = true
				$AnimatedSprite2D.animation = ANIMATION.AGITATED
			else:
				$GPUParticles2D.emitting = false
				increase_snap_timer = false
				$AnimatedSprite2D.animation = ANIMATION.STATIC
				global_position.x = default_pos.x
