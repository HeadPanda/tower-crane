class_name Block
extends RigidBody2D

@export var impact_threshold := 125
@export var despawn_time_sec: float = 5.0
@export var should_despawn: bool = false:
	set(value):
		should_despawn = value
		if should_despawn:
			despawn_timer.start()
var is_held := false:
	set(value):
		is_held = value
		if is_held:
			despawn_timer.stop()
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var sfx_timer: Timer = $SFXTimer
@onready var despawn_timer: Timer = $DespawnTimer


func _ready() -> void:
	if sfx.stream and not sfx.playing:
		sfx.play()
	
	freeze = true
	despawn_timer.wait_time = despawn_time_sec
	if should_despawn:
		despawn_timer.start()


func activate_collision(player_activated: bool = false) -> void:
	# layers
	set_collision_layer_value(3, true) # block
	set_collision_layer_value(4, false) #deattach
	if player_activated:
		set_collision_layer_value(8, true) # player activated block
	
	# masks
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)
	set_collision_mask_value(4, true)
	set_collision_mask_value(8, true)


func pickup() -> void:
	is_held = true
	set_collision_layer_value(3, false)
	set_collision_layer_value(9, false)
	set_collision_layer_value(4, true)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, true)
	freeze = false


func deactivate_collision() -> void:
	# layers
	set_collision_layer_value(3, false) # block
	set_collision_layer_value(4, false) #deattach
	set_collision_layer_value(8, false) # player activated block
	
	# masks
	set_collision_mask_value(1, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(4, false)
	set_collision_mask_value(8, false)


func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > impact_threshold:
		if sfx.stream and not sfx.playing and sfx_timer.time_left == 0:
			sfx_timer.start()
			sfx.play()


func _on_despawn_timer_timeout() -> void:
	if not is_held:
		queue_free()
