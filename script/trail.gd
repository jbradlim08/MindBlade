extends Line2D

@export var object: Node2D
@export var length_multiplier: float = 0.19 # lasted for 0.19 secs

var queue: Array
var pos: Vector2

func _ready() -> void:
	position = Vector2(0, 0)

func _process(delta) -> void:
	print('active')
	pos = object.global_position
	queue.push_front(pos)
	
	if queue.size() > (length_multiplier / delta):
		# use delta for persistent length and time
		queue.pop_back()
		
	clear_points()
	
	for point in queue:
		add_point(point)
	
func reset_queue() -> void:
	queue.clear()
	
