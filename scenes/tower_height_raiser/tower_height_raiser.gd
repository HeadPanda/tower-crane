extends Node2D

@export var raise_height: float = 100
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var raise_check_timer: Timer = $RaiseCheckTimer


func _on_raise_check_timer_timeout() -> void:
	if ray_cast_2d.is_colliding():
		var pos_y_cache = position.y
		var block: Block = ray_cast_2d.get_collider()
		var is_attached = block.get_collision_layer_value(4)
		var is_stable = await block.is_stable()
		
		if not is_attached and is_stable:
			position.y = pos_y_cache - raise_height
			print(position.y, pos_y_cache, raise_height)
