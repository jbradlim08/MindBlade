extends PathFollow2D

const SPEED: float = 0.3

@export var is_moving: bool = false

func _process(delta: float) -> void:
	if is_moving:
		progress_ratio += SPEED * delta
