extends Control

class_name ErrorMessage

@onready var label: Label = $Label
@onready var sound: AudioStreamPlayer = $Sound

var message: String

func _ready() -> void:
	label.text = message
	SoundManager.play_clip(sound, SoundManager.ERROR_MESSAGE_SOUND, 2.0, 0.8)
