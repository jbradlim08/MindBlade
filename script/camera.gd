extends Camera2D

var shake_time := 0.0

@export var shake_strength := 5.0

func _ready() -> void:
	SignalManager.on_player_hurt.connect(shake)

func _process(delta: float) -> void:
	if shake_time > 0:
		shake_time -= delta
		
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO

func shake(duration: float = 0.1) -> void:
	shake_time = duration
