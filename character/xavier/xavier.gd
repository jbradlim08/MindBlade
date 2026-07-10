extends BasePlayer


func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func attack() -> void:
	for blade in blades:
		if blade.cur_state == Blade.BladeState.ORBIT:
			blade.init_throw(get_global_mouse_position())
			change_state(PlayerState.IDLE)
			return

	print("No blade available")
	change_state(PlayerState.IDLE)
