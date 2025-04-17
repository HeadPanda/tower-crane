class_name Crane
extends CharacterBody2D


@export_group("Crane Control")
@export var speed := 200.0
@export var acceleration := 100.0
@export var friction := 1000.0
@export var top_offset := 8
@export var rotation_amount := 2.0
@export var release_delay: float = 0.5
@export var min_y_pos := 0
@export var min_x_pos := 0
@export var max_x_pos := 640

@export_group("SFX")
@export var move_sfx_speed_req := 64.0


@export_group("Chains")
@export var chain_softness: float = 0.03

var direction : Vector2
var held_block : RigidBody2D
var joint: PinJoint2D
var is_rotating := false

@onready var grab_area: Area2D = %GrabArea
@onready var hook: RigidBody2D = %Hook
@onready var chains: Node2D = $ChainContainer/Chains
@onready var rotate_timer: Timer = $RotateTimer
@onready var move_sfx: AudioStreamPlayer2D = $SFX/MoveSFX
@onready var switch_direction_sfx: AudioStreamPlayer2D = $SFX/SwitchDirectionSFX
@onready var attach_sfx: AudioStreamPlayer2D = $SFX/AttachSFX


func _ready() -> void:
	for child in chains.get_children():
		if child is PinJoint2D:
			child.softness = chain_softness
	rotate_timer.wait_time = release_delay * 3.0

func _physics_process(delta: float) -> void:
	var prev_direction_x = direction.x
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if prev_direction_x == -direction.x:
		play_switch_sfx()
	
	apply_movement(delta)
	
	handle_play_moving_sfx()
	
	if Input.is_action_just_pressed("attach"):
		_on_grab_pressed()
	
	if held_block:
		if Input.is_action_pressed("rotate_left"):
			rotate_timer.stop()
			rotate_around_hook(-rotation_amount)
		elif Input.is_action_pressed("rotate_right"):
			rotate_timer.stop()
			rotate_around_hook(rotation_amount)
		elif Input.is_action_just_released("rotate_left") or Input.is_action_just_released("rotate_right"):
			rotate_timer.start()


func apply_movement(delta: float):
	if direction.x:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	
	if direction.y:
		velocity.y = move_toward(velocity.y, direction.y * speed, acceleration * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, friction * delta)
	
	#var camera_top = get_viewport().get_camera_2d().global_position.y - get_viewport_rect().size.y / 2.0
	#if global_position.y > camera_top + top_offset:
		#global_position.y = camera_top + top_offset
		
	if global_position.y > min_y_pos + top_offset:
		global_position.y = min_y_pos + top_offset
	
	if global_position.x < min_x_pos:
		global_position.x = min_x_pos
	
	if global_position.x > max_x_pos:
		global_position.x = max_x_pos
	
	move_and_slide()


func rotate_around_hook(angle_deg: float):
	var pivot = hook.global_position
	var dir = held_block.global_position - pivot
	held_block.lock_rotation = true
	dir = dir.rotated(deg_to_rad(angle_deg))
	held_block.global_position = pivot + dir
	held_block.rotation += deg_to_rad(angle_deg)


func handle_play_moving_sfx() -> void:
	var start := 13.0
	var end := 16.0
	var is_moving = velocity.x >= move_sfx_speed_req or velocity.x <= -move_sfx_speed_req or velocity.y >= move_sfx_speed_req or velocity.y <= -move_sfx_speed_req
	
	if is_moving and not move_sfx.playing:
		var tween = get_tree().create_tween()
		tween.tween_property(move_sfx, "volume_db", 1, 5.0)
		move_sfx.play(start)
	if not is_moving and move_sfx.playing or move_sfx.get_playback_position() >= end:
		var tween = get_tree().create_tween()
		tween.tween_property(move_sfx, "volume_db", -10.0, 0.25)
		tween.tween_callback(move_sfx.stop)


func play_switch_sfx() -> void:
	switch_direction_sfx.volume_db = -40
	switch_direction_sfx.stop()
	await get_tree().create_timer(0.2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(switch_direction_sfx, "volume_db", -30, 0.15)
	switch_direction_sfx.play()


func _on_grab_pressed():
	if held_block:
		attach_sfx.play()
		# Drop the block
		if joint:
			joint.queue_free()
			joint = null
		
		var cached_block = held_block
		held_block = null
		await get_tree().create_timer(release_delay).timeout
		cached_block.set_collision_layer_value(3, true)
		cached_block.set_collision_layer_value(4, false)
		#cached_block.set_collision_mask_value(2, true)
		cached_block.lock_rotation = false
		cached_block = null
	else:
		for body in grab_area.get_overlapping_bodies():
			if body.is_in_group("Blocks"):
				attach_sfx.play()
				held_block = body
				held_block.set_collision_layer_value(3, false)
				held_block.set_collision_layer_value(4, true)
				held_block.set_collision_mask_value(2, false)
				held_block.freeze = false
				#held_block.lock_rotation = true
				
				# Create the joint
				joint = PinJoint2D.new()
				joint.softness = 0.02
				joint.bias = 0.4
				joint.position = Vector2.ZERO
				joint.node_a = hook.get_path()
				joint.node_b = held_block.get_path()
				hook.add_child(joint)
				break


func _on_rotate_timer_timeout() -> void:
	if held_block != null:
		held_block.lock_rotation = false
