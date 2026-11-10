extends Area2D

const MIN_DISTANCE_TO_PLAYER: float = 175.0

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var light: PointLight2D = $Light

var player_ref: Player
var is_player_near: bool = false
var error_message: String = "player too far from crafting spot"

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group(Constants.PLAYER_BODY_GROUP)
	canvas_layer.hide()
	light.hide()

func _on_clickzone_mouse_entered() -> void:
	light.show()

func _on_clickzone_mouse_exited() -> void:
	light.hide()

func _on_clickzone_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# if clicked by left_mouse
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		if is_player_near:
			canvas_layer.show()
			light.show()
		else:
			canvas_layer.hide()
			# instantiate prompt "too far" from crafting spot
			SignalManager.on_error_message.emit(error_message)

func _on_body_entered(body: Node2D) -> void:
	is_player_near = true

func _on_body_exited(body: Node2D) -> void:
	is_player_near = false

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		canvas_layer.hide()
