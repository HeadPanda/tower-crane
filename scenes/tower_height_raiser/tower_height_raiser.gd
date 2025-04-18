extends Node2D

@export var raise_height: float = 100
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	if ray_cast_2d.is_colliding():
		var block: Block = ray_cast_2d.get_collider()
		var is_attached = block.get_collision_layer_value(4)
		if not is_attached:
			position.y -= raise_height
