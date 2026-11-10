extends Resource

class_name RuneData

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var cost: Dictionary[MaterialData, int]

func use_rune(player: Player) -> void:
	pass   # each rune overrides this
