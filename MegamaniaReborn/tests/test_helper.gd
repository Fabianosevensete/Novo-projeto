extends GutTest

var _added_autoloads := []

func setup_autoloads():
	if not get_node_or_null("/root/EventBus"):
		var eb = load("res://scripts/core/EventBus.gd").new()
		get_tree().root.add_child(eb)
		_added_autoloads.append(eb)

func cleanup_autoloads():
	for n in _added_autoloads:
		if is_instance_valid(n):
			n.queue_free()
	_added_autoloads.clear()
