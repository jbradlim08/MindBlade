extends HBoxContainer

class_name CostEntry

@onready var texture_rect: TextureRect = $TextureRect
@onready var rune_name: Label = $RuneName

func setup(icon: Texture2D, amount: int) -> void:
	texture_rect.texture = icon
	rune_name.text = str(amount)
