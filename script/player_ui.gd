extends Control

@onready var health_bar: TextureProgressBar = $MarginContainer/HealthBar

func _ready() -> void:
	health_bar.init_setup(DataManager.get_player_hp() ,DataManager.get_max_player_hp())
	SignalManager.on_player_hurt.connect(player_hurt)
	health_bar.on_creature_die.connect(die)

func player_hurt() -> void:
	health_bar.set_hp(DataManager.get_player_hp())

func die():
	SignalManager.on_player_die.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneManager.load_main_scene()
