class_name Block
extends RigidBody2D

@export var impact_threshold := 125
@export var despawn_time_sec: float = 30.0
@export var should_despawn: bool = false:
	set(value):
		should_despawn = value
		if should_despawn and is_node_ready():
			despawn_timer.start()
var is_held := false:
	set(value):
		is_held = value
		if is_held and is_node_ready():
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

func is_stable() -> bool:
	await get_tree().create_timer(0.2).timeout
	var is_stable_linear: bool = linear_velocity.x <= 0.5 and linear_velocity.y <= 0.5
	var is_stable_angular: bool = angular_velocity <= 0.5
	
	return is_stable_linear and is_stable_angular and get_contact_count() > 0


func change_gravity(amount: float) -> void:
	gravity_scale = amount


func reset_gravity() -> void:
	gravity_scale = 1.0


func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > impact_threshold:
		if sfx.stream and not sfx.playing and sfx_timer.time_left == 0:
			sfx_timer.start()
			sfx.play()


func _on_despawn_timer_timeout() -> void:
	if not is_held:
		queue_free()
