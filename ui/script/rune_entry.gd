extends TextureButton

class_name RuneEntry

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var rune: TextureRect = $Rune
@onready var hover_background: ColorRect = $HoverBackground
@onready var sound: AudioStreamPlayer = $Sound

func setup(icon: Texture2D) -> void:
	rune.texture = icon

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		anim.play.call_deferred("selected")
	else:
		anim.play("RESET")

func _on_mouse_entered() -> void:
	hover_background.show()
	SoundManager.play_clip(sound, SoundManager.MENU_SELECTION_SOUND, -8.0, 1.0)

func _on_mouse_exited() -> void:
	hover_background.hide()
