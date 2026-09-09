extends Camera2D

var shake_time: float = 0.0

var shake_strength: float = 5.0

func _ready() -> void:
	SignalManager.on_player_hurt.connect(shake.bind(0.1, 5.0))
	SignalManager.on_player_crit.connect(shake.bind(0.1, 0.5))

func _process(delta: float) -> void:
	if shake_time > 0:
		shake_time -= delta
		
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO

func shake(duration: float, strength: float) -> void:
	shake_time = duration
	shake_strength = strength
