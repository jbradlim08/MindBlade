extends Node2D


var player_ref: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_player_crit.connect(freeze_game)
	player_ref = get_tree().get_first_node_in_group(
		 Constants.PLAYER_BODY_GROUP
	)
	player_ref.global_position = DataManager.get_level_start_pos(0)
	player_ref.set_process_unhandled_input(false)
	player_ref.set_process_input(false)
	fade_in()

func fade_in() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	# add new Black color ColorRect Node
	var fade_rect := ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fade_rect)

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
