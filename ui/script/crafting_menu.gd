extends Control

const RUNE_DIR := "res://item/rune/rune_resources/"
const RUNE_ENTRY = preload("uid://c3eummyjmckb7")
const COST_ENTRY = preload("uid://bteykmemn2xgk")

@onready var rune_list: VBoxContainer = $TextureRect/MarginContainer/HBoxContainer/RunePanel/RuneList
@onready var cost_list: VBoxContainer = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/Cost/CostList

@onready var rune_name: Label = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/RuneName

@onready var craft_slider: HSlider = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/CraftButton/CraftSlider
@onready var sell_slider: HSlider = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/SellButton/SellSlider
@onready var craftable_amount: Label = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/CraftButton/CraftableAmount
@onready var sellable_amount: Label = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/SellButton/SellableAmount
@onready var craft_button: TextureButton = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/CraftButton/CraftButton
@onready var sell_button: TextureButton = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/SellButton/SellButton

var all_runes: Array[RuneData] = []
var selected_rune: RuneData
var group := ButtonGroup.new()

func _ready() -> void:
	# every time GameData items change, update the slider, else remain the same
	SignalManager.on_items_changed.connect(update_slider)
	# everytime slider value changed, the text is also updated
	craft_slider.value_changed.connect(_on_craft_slider_changed)# everytime slider value changed, the text is also updated
	sell_slider.value_changed.connect(_on_sell_slider_changed)
	load_all_runes()
	build_rune_list()

func load_all_runes() -> void:
	# load from runes_resources folder
	for file in DirAccess.get_files_at(RUNE_DIR):
		file = file.trim_suffix(".remap")   # exported games rename files to .tres.remap
		if not file.ends_with(".tres"):
			continue
		var rune := load(RUNE_DIR + file) as RuneData # load the file as RuneData
		if rune:
			all_runes.append(rune)

func build_rune_list() -> void:
	for r in rune_list.get_children():
		r.queue_free() # refresh
	for rune in all_runes:
		var entry = RUNE_ENTRY.instantiate()
		rune_list.add_child(entry)
		entry.button_group = group  # join the shared group, so only one can be selected
		entry.setup(rune.icon)
		entry.pressed.connect(select_rune.bind(rune)) # when clicked, call select_rune(rune)
	
	# select the first one by default
	rune_list.get_child(0).button_pressed = true
	select_rune(all_runes[0])

func select_rune(rune: RuneData) -> void:
	selected_rune = rune
	load_selected_rune_info(selected_rune)

func load_selected_rune_info(rune: RuneData) -> void:
	# change the display name
	rune_name.text = selected_rune.display_name.replace(" ", "\n") # next word = new line
	
	for cost in cost_list.get_children():
		cost.queue_free() # refresh
	for material in rune.cost:
		var entry = COST_ENTRY.instantiate()
		cost_list.add_child(entry)
		entry.setup(material.icon, rune.cost[material]) # rune.cost[material] is the amount from Dict
		
	update_slider()
	
func update_slider() -> void:
	# craft
	var most_craftable = GameData.max_craftable_rune(selected_rune)
	craft_slider.max_value = most_craftable
	craft_slider.editable = most_craftable > 0
	craft_slider.scrollable = most_craftable > 0
	craftable_amount.text = str(int(craft_slider.value)) # default
	
	# sell
	var most_sellable = GameData.max_sellable_rune(selected_rune)
	sell_slider.max_value = most_sellable
	sell_slider.editable = most_sellable > 0
	sell_slider.scrollable = most_sellable > 0
	sellable_amount.text = str(int(sell_slider.value)) # default
	
func _on_craft_slider_changed(slider_value: float) -> void:
	craftable_amount.text = str(int(slider_value))
	
func _on_sell_slider_changed(slider_value: float) -> void:
	sellable_amount.text = str(int(slider_value))
