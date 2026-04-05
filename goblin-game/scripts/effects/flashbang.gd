extends Area2D

const EFFECT_TIMER: float = 1

func _input(event: InputEvent) -> void:
	if !Input.is_action_just_pressed("use"):
		return

	_trigger_animation()
	
	var children = get_overlapping_bodies()
	for child in children:
		print(child)
		if child.has_method("_flashbang"):
			child._flashbang()

func _trigger_animation() -> void:
	var sprite = $FlashCollisionShape2D/AnimatedSprite2D
	sprite.play()
	sprite.visible = true
	await get_tree().create_timer(EFFECT_TIMER).timeout
	sprite.visible = false
	sprite.stop()
