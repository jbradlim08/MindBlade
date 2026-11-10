extends TextureButton

@onready var sound: AudioStreamPlayer = $Sound
@onready var anim: AnimationPlayer = $AnimationPlayer

func _on_mouse_entered() -> void:
	anim.play("hover")
	SoundManager.play_clip(sound, SoundManager.MENU_SELECTION_SOUND, -8.0, 1.0)

func _on_mouse_exited() -> void:
	anim.play("RESET")

func _on_pressed() -> void:
	SceneManager.load_tutorial_scene()
