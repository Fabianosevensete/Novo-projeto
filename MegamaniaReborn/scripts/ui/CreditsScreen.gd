extends CanvasLayer

@onready var back_btn := $BackBtn


func _ready():
	back_btn.pressed.connect(_on_back)


func _on_back():
	visible = false
	var main = get_node("/root/GameManager").main_scene
	if main and main.main_menu:
		main.main_menu.visible = true
