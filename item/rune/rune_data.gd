extends Resource

class_name RuneData

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D

func use_rune(player: Player) -> void:
	pass   # each rune overrides this
