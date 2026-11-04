extends RigidBody2D

class_name Collectible

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var pick_up_area: Area2D = $PickUpArea
@onready var sound: AudioStreamPlayer2D = $Sound

@export var loot_materials: Array[MaterialData]

var material_data: MaterialData
var launch_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	if randf_range(0.0, 1.0) > GameData.get_drop_chance() or loot_materials.is_empty():
		queue_free()
	material_data = loot_materials.pick_random()
	sprite_2d.texture = material_data.icon
	linear_velocity = launch_velocity           # the pop
	# brief delay before it can be picked up, so it doesn't vanish on spawn
	Utils.toggle_area2d(pick_up_area, false)
	await get_tree().create_timer(0.4).timeout
	Utils.toggle_area2d(pick_up_area, true)
	timer.start()

func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group(Constants.PLAYER_BODY_GROUP):
		return
	Utils.toggle_area2d(pick_up_area, false)
	# add the collectible material inside GameData and emit signal
	GameData.add_material(material_data, 1)
	hide()
	SoundManager.play_clip(sound, SoundManager.PICKUP_SOUND, 2.0, 1.0)
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
