extends Node

const CAGE_KEY_FLAG  := 'item.mushroom_cage_key_taken'

@onready var dialogue_initial = $DialogueBoxInitial/DialogueTrigger
@onready var dialogue_end = $DialogueBoxEnd/DialogueTrigger

func _ready() -> void:
	var has_cage_key = WorldState.get_flag(CAGE_KEY_FLAG)
	if has_cage_key:
		dialogue_initial._disable_dialogue()
	else:
		dialogue_end._disable_dialogue()
