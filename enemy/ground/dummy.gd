extends StaticBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer


func _physics_process(_delta: float) -> void:
	anim.play("idle")


func take_damage(_dmg: float) -> void:
	set_physics_process(false)
	anim.play("hurt")
	await anim.animation_finished
	set_physics_process(true)
