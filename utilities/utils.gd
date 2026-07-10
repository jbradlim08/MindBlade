class_name Utils


static func toggle_area2d(area: Area2D, switch_on: bool) -> void:
	area.set_deferred("monitoring", switch_on)
	area.set_deferred("monitorable", switch_on)

static func toggle_collision_shape(shape: CollisionShape2D, switch_on: bool) -> void:
	shape.set_deferred("disabled", not switch_on)
