extends Node2D

@onready var player_node: CharacterBody2D = $"../Player"

const SNAP_TIME = 2

var increase_snap_timer = false
var snap_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if increase_snap_timer:
		snap_timer += delta
		
	if snap_timer > SNAP_TIME:
		player_node._reset_to_safe_pos()
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		snap_timer = 0
		increase_snap_timer = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		snap_timer = 0
		increase_snap_timer = false
