class_name Block
extends RigidBody2D

@export var impact_threshold := 125
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var sfx_timer: Timer = $SFXTimer


func _ready() -> void:
	if sfx.stream and not sfx.playing:
		sfx.play()


func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > impact_threshold:
		if sfx.stream and not sfx.playing and sfx_timer.time_left == 0:
			sfx_timer.start()
			sfx.play()
