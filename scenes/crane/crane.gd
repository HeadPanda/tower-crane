class_name Crane
extends CharacterBody2D


@export_group("Crane Control")
@export var speed := 150.0
@export var acceleration := 100.0
@export var friction := 900
@export var top_offset := 8
@export var rotation_amount := 1.0

@export_group("Chains")
@export var chain_softness: float = 0.03

var direction : Vector2
var held_block : RigidBody2D
var joint: PinJoint2D

@onready var grab_area: Area2D = %GrabArea
@onready var hook: RigidBody2D = %Hook
@onready var chains: Node2D = $ChainContainer/Chains


func _ready() -> void:
	for child in chains.get_children():
		if child is PinJoint2D:
			child.softness = chain_softness

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	apply_movement(delta)
	
	if Input.is_action_just_pressed("attach"):
		_on_grab_pressed()
	
	if held_block:
		if Input.is_action_pressed("rotate_left"):
			rotate_around_hook(-rotation_amount)
		elif Input.is_action_pressed("rotate_right"):
			rotate_around_hook(rotation_amount)
		elif Input.is_action_just_released("rotate_left") or Input.is_action_just_released("rotate_right"):
			held_block.lock_rotation = false


func apply_movement(delta: float):
	if direction.x:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	if direction.y:
		velocity.y = move_toward(velocity.y, direction.y * speed, acceleration * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, friction * delta)
	
	var camera_top = get_viewport().get_camera_2d().global_position.y - get_viewport_rect().size.y / 2.0
	if global_position.y > camera_top + top_offset:
		global_position.y = camera_top + top_offset
	
	move_and_slide()


func rotate_around_hook(angle_deg: float):
	var pivot = hook.global_position
	var dir = held_block.global_position - pivot
	held_block.lock_rotation = true
	dir = dir.rotated(deg_to_rad(angle_deg))
	held_block.global_position = pivot + dir
	held_block.rotation += deg_to_rad(angle_deg)


func _on_grab_pressed():
	if held_block:
		# Drop the block
		if joint:
			joint.queue_free()
			joint = null
		held_block.set_collision_layer_value(3, true)
		held_block.set_collision_layer_value(4, false)
		held_block.set_collision_mask_value(2, true)
		held_block = null
	else:
		for body in grab_area.get_overlapping_bodies():
			if body.is_in_group("Blocks"):
				held_block = body
				held_block.set_collision_layer_value(3, false)
				held_block.set_collision_layer_value(4, true)
				held_block.set_collision_mask_value(2, false)
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
