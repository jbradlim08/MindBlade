extends Control

class_name ErrorMessage

@onready var label: Label = $Label

var message: String

func _ready() -> void:
	label.text = message
