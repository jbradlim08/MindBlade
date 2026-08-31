extends HealthBar


func _ready() -> void:
	super()

func init_setup(hp) -> void:
	cur_hp = hp
	max_value = cur_hp
	set_value_no_signal(cur_hp)
	set_color()

func set_hp(hp) -> void:
	cur_hp = hp # set cur_hp in healthbar to actual hp enemy
	update_value()
