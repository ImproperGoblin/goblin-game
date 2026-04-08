extends Node

@onready var overlay = $Overlay

@onready var hearts_hud = $HUD/Hearts
@onready var heart_1 = $HUD/Hearts/HeartContainer1
@onready var heart_2 = $HUD/Hearts/HeartContainer2
@onready var heart_3 = $HUD/Hearts/HeartContainer3

@onready var fade = $Overlay/Fade

var heart_1_state: int = -1
var heart_2_state: int = -1
var heart_3_state: int = -1

const HEART_ANIMATION = {
	"STATIC_FULL": "static_full",
	"STATIC_HALF": "static_half",
	"STATIC_EMPTY": "static_empty",
	"FULL_TO_HALF": "full_to_half",
	"HALF_TO_EMPTY": "half_to_empty",
	"FULL_TO_EMPTY": "full_to_empty"
}

func _show_gameplay_ui():
	hearts_hud.show()
	overlay.show()

func _hide_gameplay_ui():
	hearts_hud.hide()
	overlay.hide()

func _fade(to_alpha: float, duration: float=1.2) -> void:
	var fade_tween := create_tween()
	fade_tween.tween_property(fade, "modulate:a", to_alpha, duration)
	await fade_tween.finished
	
func _set_fade(to_alpha: float) -> void:
	fade.modulate.a = to_alpha

func _update_hearts() -> void:
	var hp = PlayerState._get_player_hp()
	
	heart_1_state = _set_heart(heart_1, heart_1_state, clampi(hp, 0, 2))
	heart_2_state = _set_heart(heart_2, heart_2_state, clampi(hp - 2, 0, 2))
	heart_3_state = _set_heart(heart_3, heart_3_state, clampi(hp - 4, 0, 2))

func _set_heart(heart: AnimatedSprite2D, old_state: int, new_state: int) -> int:
	if(!heart):
		return 1
		
	if old_state == new_state:
		return old_state
	
	match new_state:
		2:
			heart.play(HEART_ANIMATION.STATIC_FULL)
		1:
			if old_state == 2:
				heart.play(HEART_ANIMATION.FULL_TO_HALF)
			else:
				heart.play(HEART_ANIMATION.STATIC_HALF)
		0:
			if old_state == 2:
				heart.play(HEART_ANIMATION.FULL_TO_EMPTY)
			elif old_state == 1:
				heart.play(HEART_ANIMATION.HALF_TO_EMPTY)
			else:
				heart.play(HEART_ANIMATION.STATIC_EMPTY)

	return new_state
