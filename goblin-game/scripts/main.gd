extends Node2D
var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up Level
	current_level_root = get_node("LevelRoot")
	_setup_level()


# -----------------
# LEVEL MANAGEMENT
# -----------------

func _load_level(level_number:int) -> void:
	

# Level Setup
func _setup_level() -> void:
	
	# Connect EXIT
	var exit = $LevelRoot.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)

# -----------------
# SIGNAL HANDLERS
# -----------------
func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		level += 1
		print (level)
		body.can_move = false
