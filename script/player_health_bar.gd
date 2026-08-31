extends HealthBar


func _ready() -> void:
	cur_hp = DataManager.get_player_hp()
	SignalManager.on_player_hp_change.connect(set_hp)
	super()

func set_hp(val) -> void:
	cur_hp = DataManager.get_player_hp()
	update_value()
