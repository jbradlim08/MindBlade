extends TextureButton

class_name RuneEntry

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hover_background: ColorRect = $HoverBackground

func setup(icon: Texture2D) -> void:
	texture_normal = icon

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print('toggled')
		anim.play.call_deferred("hover")
	else:
		anim.play("RESET")

func _on_mouse_entered() -> void:
	hover_background.show()

func _on_mouse_exited() -> void:
	hover_background.hide()
