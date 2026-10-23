extends Label

@onready var label: Label = $"."

func _ready() -> void:
	label.pivot_offset = label.size / 2
	position.x = 0.0
