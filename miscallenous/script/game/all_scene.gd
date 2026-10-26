extends Node2D

class_name BaseScene

enum SceneSelection {
	MAIN,
	LEVEL,
	TUTORIAL
}

const PAUSE_MENU = preload("res://miscallenous/scene/ui/pause_menu.tscn")

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@export var scene_selection: SceneSelection
@export var checkpoint: Node2D

var player_ref: Player
var can_pause: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and can_pause:
		open_pause_menu()

func _ready() -> void:
	SignalManager.on_player_crit.connect(freeze_game)
	
	player_ref = get_tree().get_first_node_in_group(
		 Constants.PLAYER_BODY_GROUP
	)
	if scene_selection == SceneSelection.LEVEL:
		set_processes(true)
		SignalManager.on_player_put_checkpoint.connect(move_checkpoint)
	else:
		set_processes(false)
	# starts fade in
	fade_in()

func set_processes(val: bool) -> void:
	player_ref.set_process_unhandled_input(val)
	player_ref.set_process_input(val)

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

	player_ref.can_get_input = false
	GameData.set_checkpoint_pos(GameData.get_level_start_pos(scene_select()))
	player_ref.global_position = GameData.get_checkpoint_pos()
	if scene_selection == SceneSelection.LEVEL:
		move_checkpoint(player_ref.global_position)
	await get_tree().create_timer(0.3).timeout   # time to land

	# zoom in and fade in together
	player_ref.entrance()
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await tween.finished
	can_pause = true

	player_ref.can_get_input = true
	layer.queue_free()

func scene_select() -> String:
	match scene_selection:
		SceneSelection.MAIN:
			return "main"
		SceneSelection.LEVEL:
			return "level"
		SceneSelection.TUTORIAL:
			return "tutorial"
		
	return "main"

func freeze_game() -> void:
	print('game freeze')
	Engine.time_scale = 0.0
	await get_tree().create_timer(GameData.get_freeze_timer(), 
								true, 
								false, 
								true).timeout
	Engine.time_scale = 1.0

func open_pause_menu() -> void:
	var layer := PAUSE_MENU.instantiate()
	canvas_layer.add_child(layer)
	get_tree().paused = true

func move_checkpoint(pos: Vector2) -> void:
	checkpoint.global_position = pos
