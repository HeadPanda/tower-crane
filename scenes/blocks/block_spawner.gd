class_name BlockSpawner
extends Node2D

@export var block_types : Array[PackedScene]
@export var rotations : Array[float]
@export var spawn_delay_variance: float = 5.0
@export var spawn_delay: float = 5.0
@onready var area_2d: Area2D = $Area2D
@onready var blocks_container: Node2D = get_node("/root/Level/Main/Blocks")
@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	spawn_timer.wait_time = spawn_delay + randf_range(-spawn_delay, spawn_delay_variance)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	spawn_timer.wait_time = spawn_delay + randf_range(-1.0, spawn_delay_variance)
	await get_tree().physics_frame
	if area_2d.has_overlapping_bodies() or area_2d.has_overlapping_areas():
		return
	spawn()


func spawn() -> void:
	var random_block: RigidBody2D = block_types.pick_random().instantiate()
	
	if len(rotations) > 0:
		random_block.rotation = rotations.pick_random()
	
	random_block.global_position = global_position
	blocks_container.add_child(random_block)
	
