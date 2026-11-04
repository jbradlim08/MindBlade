extends Control

const ITEM_SLOT = preload("res://ui/scene/item_slot.tscn")

@onready var item_container: VBoxContainer = $MarginContainer/ItemContainer
@onready var material_grid: GridContainer = $MarginContainer/ItemContainer/MaterialContainer/PanelContainerItem/MarginContainer/MaterialGrid
@onready var rune_grid: GridContainer = $MarginContainer/ItemContainer/RuneContainer/PanelContainerItem/MarginContainer/RuneGrid
@onready var bag_button: TextureButton = $BagButton


func _ready() -> void:
	bag_button.focus_mode = Control.FOCUS_NONE # so space and enter don't affect
	item_container.hide()
	# signal: everytime something change - refresh
	SignalManager.on_items_changed.connect(refresh)
	refresh()

func refresh() -> void:
	# remove everything
	for child in material_grid.get_children():
		child.queue_free()
	for child in rune_grid.get_children():
		child.queue_free()
		
	# renew everything
	for material in GameData.materials:
		var slot := ITEM_SLOT.instantiate()
		material_grid.add_child(slot)
		slot.material_setup(material, GameData.materials[material])
	for rune in GameData.runes:
		var slot := ITEM_SLOT.instantiate()
		material_grid.add_child(slot)
		slot.rune_setup(rune, GameData.runes[rune])

func _on_bag_button_pressed() -> void:
	item_container.visible = not item_container.visible
