extends CharacterBody2D

const SPEED: float = 100
const GRAVITY = 15
const BOUNCE_TIMER: float = 4
const ANIMATION = {
	"PATROLLING": "patrolling",
	"BOUNCE_PAD": "bounce-pad"
}

const JUMP_PAD_HEIGHT = -1200
const JUMP_BOOST_MULTIPLIER = 2

var is_aggressive: bool = true

@export_range(-1, 1) var dir: int = 1

func _on_ready() -> void:
	$AnimatedSprite2D.animation = ANIMATION.PATROLLING
	if dir == 0:
		dir = 1
	$AnimatedSprite2D.flip_h = false if dir == 1 else true

func _physics_process(delta: float) -> void:
	if !is_aggressive:
		return
		
	var right_wall_collider = $RightWallRay.get_collider()
	var left_wall_collider = $LeftWallRay.get_collider()
	
	var right_wall_collider_name = right_wall_collider.name if right_wall_collider else null
	var left_wall_collider_name = left_wall_collider.name if left_wall_collider else null
	
	print(left_wall_collider_name)

	if dir == 1 and (!$RightRay.is_colliding() or ($RightWallRay.is_colliding()) and right_wall_collider_name != 'Player'):
		$AnimatedSprite2D.flip_h = true
		_wait_dir_changed(-1)
	if dir == -1 and (!$LeftRay.is_colliding() or ($LeftWallRay.is_colliding()) and left_wall_collider_name != 'Player'):
		$AnimatedSprite2D.flip_h = false
		_wait_dir_changed(1)
		
	velocity.x = lerp(velocity.x, dir * SPEED, 10.0 * delta)
	velocity.y += GRAVITY
	move_and_slide()

## ToDo: Remove and replace with flash trigger
func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_F) and is_aggressive:
		_wait_bounce_pad_mode()

func _wait_bounce_pad_mode() -> void:
	_swap_aggressive_state()
	await get_tree().create_timer(BOUNCE_TIMER).timeout
	_swap_aggressive_state()

func _swap_aggressive_state():
	is_aggressive = !is_aggressive
	$BounceArea2D/CollisionShape2D.disabled = is_aggressive
	$HurtboxArea2D/CollisionShape2D.disabled = !is_aggressive
	$AnimatedSprite2D.animation = ANIMATION.PATROLLING if is_aggressive else ANIMATION.BOUNCE_PAD

func _wait_dir_changed(new_dir: int) -> void:
	#await get_tree().create_timer(0.5).timeout
	dir = new_dir

# ToDo: change to a different reset?
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and is_aggressive:
		body._bounce_away_from_enemy(self)
		body._reduce_hp(1)

func _on_bounce_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" && !is_aggressive:
		body.velocity.y = JUMP_PAD_HEIGHT
		body._set_jump_boost(JUMP_BOOST_MULTIPLIER)
