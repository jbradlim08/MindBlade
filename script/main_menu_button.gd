extends TextureButton

@export var label_name: String

@onready var label: Label = $Control/Label
@onready var anim: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = label_name
	anim.play("reset")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	anim.play("hover")

func _on_mouse_exited() -> void:
	anim.play("RESET")


func _on_pressed() -> void:
	print('button pressed')
	anim.play("hover")
