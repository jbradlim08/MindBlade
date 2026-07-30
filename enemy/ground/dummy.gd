extends GroundEnemy

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func call_me() -> void:
	print('hell')
