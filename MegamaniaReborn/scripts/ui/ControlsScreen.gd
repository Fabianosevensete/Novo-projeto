extends CanvasLayer

@onready var back_btn := $BackBtn


func _ready():
	back_btn.pressed.connect(_on_back)


func _on_back():
	visible = false
	var gm = get_node("/root/GameManager")
	var main = gm.main_scene
	if main:
		if gm.current_state == gm.GameState.PLAYING or gm.current_state == gm.GameState.PAUSED:
			if main.pause_menu:
				main.pause_menu.visible = true
		elif gm.current_state == gm.GameState.META:
			if main.meta_menu:
				main.meta_menu.visible = true
		else:
			if main.main_menu:
				main.main_menu.visible = true
