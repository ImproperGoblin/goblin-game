extends Node

@onready var pause_menu = $MenuLayer/PauseMenu
@onready var death_menu = $MenuLayer/DeathMenu

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	pause_menu.hide()
	death_menu.hide()

func _input(event):
	if event.is_action_pressed('pause'):
		if death_menu.visible:
			return

		if pause_menu.visible:
			_resume_game()
		else:
			_open_pause_menu()

func _open_pause_menu():
	get_tree().paused = true
	pause_menu.show()

func _resume_game():
	pause_menu.hide()
	get_tree().paused = false

func _show_death_menu():
	get_tree().paused = true
	pause_menu.hide()
	death_menu.show()
	
func _hide_death_menu():
	death_menu.hide()
	get_tree().paused = false

func _exit_game():
	get_tree().quit()
