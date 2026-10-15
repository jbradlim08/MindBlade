extends TextureButton

enum OptionMenu{
	PLAY,
	EQUIPMENT,
	SETTING,
	QUIT
}

@export var label_name: String
@export var button_option: OptionMenu

@onready var label: Label = $Control/Label
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sound: AudioStreamPlayer2D = $Sound

func _ready() -> void:
	label.text = label_name
	anim.play("RESET")

func _on_mouse_entered() -> void:
	anim.play("hover")
	SoundManager.play_clip(sound, SoundManager.MENU_SELECTION_SOUND, 0.0, 1.0)

func _on_mouse_exited() -> void:
	anim.play("RESET")

func _on_pressed() -> void:
	match button_option:
		OptionMenu.PLAY:
			SceneManager.load_level_scene()
		OptionMenu.EQUIPMENT:
			pass
		OptionMenu.SETTING:
			pass
		OptionMenu.QUIT:
			SceneManager.quit_game()
