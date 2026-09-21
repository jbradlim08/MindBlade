extends TextureProgressBar

class_name HealthBar

# Color
const COLOR_DANGER: Color = Color("#cc0000")
const COLOR_MIDDLE: Color = Color("#ff9900")
const COLOR_NORMAL: Color = Color("#33cc33")
const COLOR_MAX: Color = Color("#baffd3")

@export var cur_hp: int = 0
@export var max_hp: int = 100
@export var _size: Vector2 = Vector2.ZERO
@export var _position: Vector2 = Vector2.ZERO

signal on_creature_die

func init_setup(new_hp, new_max_hp) -> void:
	cur_hp = new_hp
	max_hp = new_max_hp
	
	max_value = max_hp
	set_value(cur_hp)
	print(value, max_value)
	
	set_color()
	set_size_and_position()
	
func set_color() -> void:
	if value < max_hp * 0.3:
		tint_progress = COLOR_DANGER
	elif value < max_hp * 0.65:
		tint_progress = COLOR_MIDDLE
	elif value < max_hp:
		tint_progress = COLOR_NORMAL
	else:
		# max health
		tint_progress = COLOR_MAX

func set_size_and_position() -> void:
	size = _size
	position = _position

func set_hp(new_hp) -> void:
	cur_hp = new_hp
	value = cur_hp
	if cur_hp <= 0:
		on_creature_die.emit()
	set_color()
