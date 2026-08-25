extends Line2D

@export var object: Node2D
@export var MAX_LENGTH: int = 20

var queue: Array
var pos: Vector2

func _ready() -> void:
	position = Vector2(0, 0)

func _process(delta) -> void:
	pos = object.global_position
	queue.push_front(pos)
	
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
	
	clear_points()
	
	for point in queue:
		add_point(point)
	
