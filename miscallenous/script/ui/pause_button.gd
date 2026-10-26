extends Control

enum PlayerSelect{
	CONTINUE,
	MAIN
}

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $HBoxContainer/Label

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
		PlayerSelect.MAIN:
			get_tree().paused = false    # pause
			get_parent().get_parent().queue_free()
			SceneManager.load_main_scene()

func _on_mouse_entered() -> void:
	anim.play("hover")

func _on_mouse_exited() -> void:
	anim.play("RESET")
