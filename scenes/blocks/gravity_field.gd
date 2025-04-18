extends Area2D

@export var gravity_amount: float = 0.1


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("change_gravity"):
		body.change_gravity(gravity_amount)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("reset_gravity"):
		body.reset_gravity()
