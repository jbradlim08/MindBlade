extends Player


func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func throw() -> void:
	for blade in blades:
		if blade.cur_state == Blade.BladeState.ORBIT:
			blade.set_target(get_global_mouse_position())
			return
