extends Node

func _ready():
	var scene = load("res://scenes/ui/MetaMenu.tscn")
	if scene:
		var inst = scene.instantiate()
		print("Instantiated, children: ", inst.get_child_count())
		for c in inst.get_children():
			print("  Child: ", c.name)
		inst.free()
	get_tree().quit()
