class_name Utils


static func toggle_area2d(area: Area2D, switch_on: bool) -> void:
	area.set_deferred("monitoring", switch_on)
	area.set_deferred("monitorable", switch_on)

static func toggle_collision_shape(shape: CollisionShape2D, switch_on: bool) -> void:
	shape.set_deferred("disabled", not switch_on)

static func toggle_col_layer_mask(obj, number: int, val: bool) -> void:
	obj.set_collision_mask_value(number, val)
	obj.set_collision_layer_value(number, val)
