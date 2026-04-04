extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_parent().get_node("Player")
const speed: float = 35.0
var gravity = 15

var is_aggressive: bool = true

@export_range(-1, 1) var dir: int = 1

func _on_ready() -> void:
	$AnimatedSprite2D.animation = "patrolling"
	if dir == 0:
		dir = 1
	$AnimatedSprite2D.flip_h = false if dir == 1 else true

func _physics_process(delta: float) -> void:
	if !is_aggressive:
		return
	if dir == 1 and (!$RightRay.is_colliding() or $RightWallRay.is_colliding()):
		$AnimatedSprite2D.flip_h = true
		_wait_dir_changed(-1)
	if dir == -1 and (!$LeftRay.is_colliding() or $LeftWallRay.is_colliding()):
		$AnimatedSprite2D.flip_h = false
		_wait_dir_changed(1)
		
	velocity.x = lerp(velocity.x, dir * speed, 10.0 * delta)
	velocity.y += gravity
	move_and_slide()

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_F):
		_wait_mushroom_is_bounce()

func _wait_mushroom_is_bounce() -> void:
	_swap_animation(false)
	await get_tree().create_timer(1).timeout
	_swap_animation(true)

func _swap_animation(set_agressive: bool):
	is_aggressive = set_agressive
	$BounceCollisionShape2d.disabled = set_agressive
	$EnemyArea2D/EnemyCollisionShape2D.disabled = !set_agressive
	$AnimatedSprite2D.animation = "patrolling" if set_agressive else "bounce-pad"

func _wait_dir_changed(new_dir: int) -> void:
	await get_tree().create_timer(0.5).timeout
	dir = new_dir

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player_node && is_aggressive:
		print("you died :(") # put reset here, use get_tree().call_deferred("reload_current_scene)
	
