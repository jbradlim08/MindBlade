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
@export var max_health: int = 100

func _ready() -> void:
	SignalManager.on_player_hp_change.connect(update_value)
	value = DataManager.get_player_hp()
	set_color()

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

func update_value() -> void:
	value = DataManager.get_player_hp()
	if value <= 0:
		print("player died")
		# died.emit()
	set_color()
