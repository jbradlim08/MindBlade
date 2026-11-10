extends Area2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	canvas_layer.hide()



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(Constants.PLAYER_BODY_GROUP):
		canvas_layer.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(Constants.PLAYER_BODY_GROUP):
		canvas_layer.hide()
