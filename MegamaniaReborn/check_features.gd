extends Node
func _ready():
	print("headless_feature: ", OS.has_feature("headless"))
	print("editor_feature: ", OS.has_feature("editor"))
	print("standalone_feature: ", OS.has_feature("standalone"))
	print("display_server: ", DisplayServer.get_name())
	get_tree().quit()
