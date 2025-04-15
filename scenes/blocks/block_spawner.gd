class_name BlockSpawner
extends Node2D

@export var block_types : Array[PackedScene]
@onready var area_2d: Area2D = $Area2D
@onready var blocks_container: Node2D = get_node("/root/Level/Main/Blocks")


func _on_spawn_timer_timeout() -> void:
	await get_tree().physics_frame
	if area_2d.has_overlapping_bodies() or area_2d.has_overlapping_areas():
		return
	
	var random_block: RigidBody2D = block_types.pick_random().instantiate()
	random_block.global_position = global_position
	blocks_container.add_child(random_block)
