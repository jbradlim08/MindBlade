extends Node2D


var player_ref: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group(
		 Constants.PLAYER_BODY_GROUP
	)
	player_ref.set_process_unhandled_input(false)
	player_ref.set_process_input(false)
	player_ref.global_position = DataManager.get_level_start_pos(0)
	SignalManager.on_player_crit.connect(freeze_game)


func freeze_game() -> void:
	print('game freeze')
	Engine.time_scale = 0.0
	await get_tree().create_timer(DataManager.get_freeze_timer(), 
								true, 
								false, 
								true).timeout
	Engine.time_scale = 1.0
