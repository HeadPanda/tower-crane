extends Label

signal drop_count_change(drop_count: int)

@export var drop_count: int = 0:
	set(value):
		drop_count = int(value)
		text = "Blocks Dropped: %s" % str(drop_count)


func _ready() -> void:
	for zone: BlockDeletionZone in get_tree().get_nodes_in_group("Block Deletion Zone"):
		zone.block_removed.connect(increment)


func increment() -> void:
	drop_count += 1
	drop_count_change.emit(drop_count)
