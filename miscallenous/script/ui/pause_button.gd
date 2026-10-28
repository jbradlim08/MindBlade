extends Control

enum PlayerSelect{
	CONTINUE,
	MAIN
}

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $HBoxContainer/Label
@onready var sound: AudioStreamPlayer2D = $Sound

@export var label_name: String
@export var selection: PlayerSelect

func _ready() -> void:
	label.text = label_name
	
func _gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed("left-click"):
		return
	accept_event()
	match selection:
		PlayerSelect.CONTINUE:
			get_tree().paused = false   # resume
			get_parent().get_parent().queue_free() 
			# self parent is VBoxContainer, and VBoxContainer parent is PauseMenu, so double parents
		PlayerSelect.MAIN:
			get_tree().paused = false    # resume
			get_parent().get_parent().queue_free()
			SceneManager.load_main_scene()

func _on_mouse_entered() -> void:
	anim.play("hover")
	SoundManager.play_clip(sound, SoundManager.MENU_SELECTION_SOUND, 0.0, 1.0)

func _on_mouse_exited() -> void:
	anim.play("RESET")
