extends Control
class_name ItemSlot

@onready var icon: TextureRect = $Icon
@onready var amount: Label = $Amount

var rune: RuneData

func material_setup(mtrial: MaterialData, count: int) -> void:
	icon.texture = mtrial.icon
	amount.text = str(count)
	tooltip_text = String(mtrial.name)   # hover shows the name

func rune_setup(r: RuneData, count: int) -> void:
	self.rune = r
	icon.texture = r.icon
	amount.text = str(count)
	tooltip_text = String(r.name)   # hover shows the name
