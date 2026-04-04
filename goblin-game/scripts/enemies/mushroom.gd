extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_parent().get_node("Player")
const speed: float = 35.0
var gravity = 15

var is_aggressive: bool = true

@export_range(-1, 1) var dir: int = 1

func _on_ready() -> void:
	if dir == 0:
		dir = 1
	$AnimatedSprite2D.flip_h = false if dir == 1 else true

func _physics_process(delta: float) -> void:
	if dir == 1 and (!$RightRay.is_colliding() or $RightWallRay.is_colliding()):
		$AnimatedSprite2D.flip_h = true
		_wait_dir_changed(-1)
	if dir == -1 and (!$LeftRay.is_colliding() or $LeftWallRay.is_colliding()):
		$AnimatedSprite2D.flip_h = false
		_wait_dir_changed(1)
		
	velocity.x = lerp(velocity.x, dir * speed, 10.0 * delta)
	velocity.y += gravity
	move_and_slide()
	
	
func _wait_dir_changed(new_dir) -> void:
	await get_tree().create_timer(0.5).timeout
	dir = new_dir

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player_node:
		print("you died :(") # put reset here, use get_tree().call_deferred("reload_current_scene)
	
