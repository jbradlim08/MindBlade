extends Control

enum WheelSelection{
	SLOT1,
	SLOT2,
	SLOT3,
	SLOT4,
	CANCEL
}

const SLOT_SIZE: int = 4

@onready var slots: Array[ItemSlot] = [
	$RuneSlots/RuneSlot1, 
	$RuneSlots/RuneSlot2, 
	$RuneSlots/RuneSlot3, 
	$RuneSlots/RuneSlot4]
@onready var pointer: TextureRect = $Pointer

var wheel_select: WheelSelection

func _ready() -> void:
	hide()
	load_runes()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("rune"):
		global_position = get_global_mouse_position()
		show()
	if event.is_action_released("rune"):
		hide()
		use_rune()

func _process(_delta) -> void:
	if visible == true:
		move_pointer()

func load_runes() -> void:
	for i in SLOT_SIZE:
		# only show what we have
		if i < GameData.runes.size():
			var rune: RuneData = GameData.runes.keys()[i]
			slots[i].rune_setup(rune, GameData.runes[rune])
			slots[i].show()
		else:
			slots[i].hide()

func get_angle() -> float:
	# never returns a negative number, only from 0 - 360
	return fposmod(rad_to_deg(global_position.angle_to_point(get_global_mouse_position())), 360)

func move_pointer() -> void:
	# happen every frame
	var angle = get_angle()
	# slot 1
	if angle == 0.0:
		pointer.hide()
	else:
		pointer.show()
	
	if angle > 180 and angle <= 225:
		set_pointer_rot(292.5)
		wheel_select = WheelSelection.SLOT1
	# slot 2
	elif angle > 225 and angle <= 270:
		set_pointer_rot(337.5)
		wheel_select = WheelSelection.SLOT2
	# slot 3
	elif angle > 270 and angle <= 315:
		set_pointer_rot(22.5)
		wheel_select = WheelSelection.SLOT3
	# slot 4
	elif angle > 315 and angle <= 360:
		set_pointer_rot(67.5)
		wheel_select = WheelSelection.SLOT4
	# cancel
	else:
		set_pointer_rot(180)
		wheel_select = WheelSelection.CANCEL

func use_rune():
	match wheel_select:
		WheelSelection.SLOT1:
			use_rune_in_slot(0)
		WheelSelection.SLOT2:
			use_rune_in_slot(1)
		WheelSelection.SLOT3:
			use_rune_in_slot(2)
		WheelSelection.SLOT4:
			use_rune_in_slot(3)
		WheelSelection.CANCEL:
			return

func use_rune_in_slot(idx: int) -> void:
	print(idx)
	var selected_rune = slots[idx].rune
	if selected_rune == null:
		return
	selected_rune.activate()

func set_pointer_rot(val: float) -> void:
	pointer.rotation = deg_to_rad(val)
