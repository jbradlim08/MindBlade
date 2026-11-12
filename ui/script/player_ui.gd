extends Control

@onready var health_bar: HealthBar = $VBoxContainer/MarginContainer/HealthBar

func _ready() -> void:
	health_bar.init_setup(GameData.get_player_hp() ,GameData.get_max_player_hp())
	SignalManager.on_player_hurt.connect(set_player_hp)
	SignalManager.on_player_healed.connect(set_player_hp)
	health_bar.on_creature_die.connect(die)

func set_player_hp(_arg = null) -> void:
	health_bar.set_hp(GameData.get_player_hp())

func die():
	# signal: player die, respawn
	SignalManager.on_player_die.emit()
