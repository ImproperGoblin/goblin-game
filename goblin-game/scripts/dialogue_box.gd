extends Node

var level_root: Node = null

func _ready() -> void:
	$Label.visible_ratio = 0
	level_root = get_node('LevelRoot')
	var dialogue_trigger = level_root.get_node_or_null("DialogueTrigger")
	if dialogue_trigger:
		dialogue_trigger.body_entered.connect(_display_dialogue)
	
func _display_dialogue() -> void:
	var dialogue_tween := create_tween()
	dialogue_tween.tween_property($Label, "visible_ratio", 1, 1.5)
	await dialogue_tween.finished
