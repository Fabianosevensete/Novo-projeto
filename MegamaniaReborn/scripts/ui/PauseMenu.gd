extends CanvasLayer

@onready var resume_btn := $VBox/ResumeBtn
@onready var settings_btn := $VBox/SettingsBtn
@onready var controls_btn := $VBox/ControlsBtn
@onready var quit_btn := $VBox/QuitBtn


func _ready():
	resume_btn.pressed.connect(_on_resume)
	settings_btn.pressed.connect(_on_settings)
	controls_btn.pressed.connect(_on_controls)
	quit_btn.pressed.connect(_on_quit)


func _on_resume():
	var gm = get_node("/root/GameManager")
	gm.change_state(gm.GameState.PLAYING)


func _on_settings():
	visible = false
	var main = get_node("/root/GameManager").main_scene
	if main and main.settings_menu:
		main.settings_menu.visible = true


func _on_controls():
	visible = false
	var main = get_node("/root/GameManager").main_scene
	if main and main.controls_screen:
		main.controls_screen.visible = true


func _on_quit():
	var gm = get_node("/root/GameManager")
	gm.change_state(gm.GameState.MENU)
