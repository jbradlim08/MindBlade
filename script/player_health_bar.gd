extends HealthBar


func _ready() -> void:
	cur_hp = DataManager.get_player_hp()
	SignalManager.on_player_hp_change.connect(set_hp)
	on_creature_die.connect(die)
	super()

func set_hp() -> void:
	cur_hp = DataManager.get_player_hp()
	update_value()

func die():
	SignalManager.on_player_die.emit()
