extends Area2D

@onready var detector: RayCast2D = $Detector
@onready var detector_2: RayCast2D = $Detector2

const SPEED: int = 200

var dir: float = 1.0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += dir * SPEED * delta
	
	check_detectors()

func check_detectors() -> void:
	# right detectors
	if not detector.is_colliding() or \
	   not detector_2.is_colliding():
		dir = -dir
		detector.position.x *= -1.0
		detector_2.position.x *= -1.0
