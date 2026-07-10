extends CanvasLayer

@onready var title_label := $TitleLabel
@onready var version_label := $VersionLabel
@onready var credits_display := $CreditsDisplay
@onready var garage_button := $BottomRow/GarageButton
@onready var start_button := $BottomRow/StartButton
@onready var controls_button := $BottomRow/HBox/ControlsButton
@onready var credits_btn := $BottomRow/HBox/CreditsButton
@onready var mode_desc := $ModeContainer/ModeDesc
@onready var arcade_btn := $ModeContainer/ArcadeBtn
@onready var boss_rush_btn := $ModeContainer/BossRushBtn
@onready var survival_btn := $ModeContainer/SurvivalBtn
@onready var daily_btn := $ModeContainer/DailyBtn

const Constants = preload("res://scripts/utils/Constants.gd")

var selected_mode := Constants.GameMode.ARCADE
var mode_buttons := []
var _last_credits := -1


func _ready():
	title_label.text = Constants.GAME_TITLE
	version_label.text = "v" + Constants.GAME_VERSION
	garage_button.pressed.connect(_on_garage)
	start_button.pressed.connect(_on_start)
	controls_button.pressed.connect(_on_controls)
	credits_btn.pressed.connect(_on_credits)
	mode_buttons = [arcade_btn, boss_rush_btn, survival_btn, daily_btn]
	for i in range(mode_buttons.size()):
		var idx = i
		mode_buttons[i].pressed.connect(func(): _select_mode(idx))
	_select_mode(0)


func _process(_delta):
	var save = get_node_or_null("/root/SaveManager")
	if save and save.credits != _last_credits:
		_last_credits = save.credits
		credits_display.text = "MC: " + str(_last_credits)


func _select_mode(idx: int):
	selected_mode = idx
	mode_desc.text = Constants.MODE_DESCRIPTIONS[idx]
	for i in range(mode_buttons.size()):
		var color = Color(0, 1, 1, 1) if i == idx else Color(0.5, 0.5, 0.5, 1)
		mode_buttons[i].add_theme_color_override("font_color", color)
	start_button.grab_focus()


func _on_start():
	var gm = get_node("/root/GameManager")
	gm.set_mode(selected_mode)
	gm.change_state(gm.GameState.PLAYING)


func _on_garage():
	var gm = get_node("/root/GameManager")
	gm.change_state(gm.GameState.META)


func _on_controls():
	var main = get_node("/root/GameManager").main_scene
	if main and main.controls_screen:
		visible = false
		main.controls_screen.visible = true


func _on_credits():
	var main = get_node("/root/GameManager").main_scene
	if main and main.credits_screen:
		visible = false
		main.credits_screen.visible = true
