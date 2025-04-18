extends Area2D

signal block_removed()


func remove_block(block: Block) -> void:
	block.queue_free()
	block_removed.emit()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Blocks"):
		remove_block(body)


#func _on_area_entered(area: Area2D) -> void:
	#var parent = area.get_parent()
	#if parent != null and parent.is_in_group("Blocks"):
		#remove_block(parent)
