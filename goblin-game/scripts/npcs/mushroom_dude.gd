extends Node2D

const NPC_STATE_FLAG := 'npc.mushroom_man.state'
const CAGE_KEY_FLAG  := 'item.mushroom_cage_key_taken'

@onready var _cage := $Cage
@onready var _area := $Cage/Area2D

func _ready() -> void:
	_area.body_entered.connect(_on_cage_area_body_entered)
	_update_state()

func _update_state() -> void:
	if WorldState.get_flag(NPC_STATE_FLAG) == 'free':
		if is_instance_valid(_cage):
			_cage.queue_free()
		
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "celebrate"
		$AnimatedSprite2D.play()

func _on_cage_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if WorldState.is_true(CAGE_KEY_FLAG):
			WorldState.set_flag(NPC_STATE_FLAG, 'free')
			AudioManager._play_sound_effect('win')
			_update_state()
