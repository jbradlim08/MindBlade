extends GroundEnemy


func _ready() -> void:
	hp = DataManager.get_dummy_hp()
	super()

func _physics_process(delta: float) -> void:
	super(delta)
