extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed('pause'):
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()

func _pause_game():
	get_tree().paused = true
	show()

func _resume_game():
	hide()
	get_tree().paused = false


func _on_button_continue_pressed() -> void:
	_resume_game()

func _on_button_quit_pressed() -> void:
	get_tree().quit()
