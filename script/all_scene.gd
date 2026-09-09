extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_player_crit.connect(freeze_game)
	GameManager.can_get_input = true


func freeze_game() -> void:
	print('game freeze')
	Engine.time_scale = 0.0
	await get_tree().create_timer(DataManager.get_freeze_timer(), 
								true, 
								false, 
								true).timeout
	Engine.time_scale = 1.0
