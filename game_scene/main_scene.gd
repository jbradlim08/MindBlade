extends Control


func _ready() -> void:
	fade_in()

func fade_in() -> void:
	# new CanvasLayer
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	# add new Black color ColorRect Node
	var fade_rect := ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(fade_rect)

	await get_tree().create_timer(0.3).timeout
	# fade in
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await tween.finished

	layer.queue_free()
