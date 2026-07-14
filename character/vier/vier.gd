extends Player


func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func idle() -> void:
	anim.play("idle")

func run() -> void:
	anim.play("run")

func jump() -> void:
	anim.play("jump")
	
func fall() -> void:
	anim.play("fall")

func attack() -> void:
	anim.play("attack")

func throw() -> void:
	for blade in blades:
		if blade.cur_state == Blade.BladeState.ORBIT:
			blade.init_throw(get_global_mouse_position())
			set_state(PlayerState.IDLE)
			return

	print("No blade available")
	set_state(PlayerState.IDLE)
