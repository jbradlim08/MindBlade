extends Node2D

var player_ref: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_player_crit.connect(freeze_game)
	player_ref = get_tree().get_first_node_in_group(
		 Constants.PLAYER_BODY_GROUP
	)
	SceneManager.set_checkpoint_pos(DataManager.get_level_start_pos(1))
	
	fade_in()
	
	player_ref.set_process_unhandled_input(true)
	player_ref.set_process_input(true)

func fade_in() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	var fade_rect := ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fade_rect)

	# blackout: nothing is paused, so the player falls and goes idle for real
	player_ref.can_get_input = false
	player_ref.global_position = SceneManager.get_checkpoint_pos()
	await get_tree().create_timer(0.2).timeout   # time to land

	# zoom in and fade in together
	player_ref.entrance()
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await tween.finished

	player_ref.can_get_input = true
	layer.queue_free()

func freeze_game() -> void:
	print('game freeze')
	Engine.time_scale = 0.0
	await get_tree().create_timer(DataManager.get_freeze_timer(), 
								true, 
								false, 
								true).timeout
	Engine.time_scale = 1.0
