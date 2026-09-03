extends TextureProgressBar

class_name HealthBar

# Color
const COLOR_DANGER: Color = Color("#cc0000")
const COLOR_MIDDLE: Color = Color("#ff9900")
const COLOR_NORMAL: Color = Color("#33cc33")
const COLOR_MAX: Color = Color("#baffd3")

@export var level_low: int = 30
@export var level_med: int = 65
@export var level_max: int = 100
@export var max_hp: int = 100
@export var _size: Vector2 = Vector2.ZERO
@export var _position: Vector2 = Vector2.ZERO

var cur_hp: float = 0.0

signal on_creature_die

func _ready() -> void:
	# assign value here
	value = cur_hp
	max_value = max_hp
	set_color()
	set_size_and_position()

func set_color() -> void:
	if value < level_low:
		tint_progress = COLOR_DANGER
	elif value < level_med:
		tint_progress = COLOR_MIDDLE
	elif value < level_max:
		tint_progress = COLOR_NORMAL
	else:
		# max health
		tint_progress = COLOR_MAX

func set_size_and_position() -> void:
	size = _size
	position = _position

func update_value() -> void:
	if cur_hp <= 0:
		on_creature_die.emit()
	value = cur_hp
	set_color()
