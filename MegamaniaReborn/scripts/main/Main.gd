extends Node

const Constants = preload("res://scripts/utils/Constants.gd")

@onready var game_world := $GameWorld
@onready var player := $GameWorld/Player
@onready var hud := $HUD
@onready var parallax := $ParallaxStarfield
@onready var main_menu := $MainMenu
@onready var meta_menu := $MetaMenu
@onready var pause_menu := $PauseMenu
@onready var settings_menu := $SettingsMenu
@onready var controls_screen := $ControlsScreen
@onready var credits_screen := $CreditsScreen

var _game_started := false


func _ready():
	var event_bus = get_node("/root/EventBus")
	var game_manager = get_node("/root/GameManager")
	game_manager.main_scene = self
	game_manager.player_ref = player
	event_bus.player_died.connect(_on_player_died)
	event_bus.game_state_changed.connect(_on_game_state_changed)
	_hide_all_menus()
	_show_menu()


func _hide_all_menus():
	if main_menu: main_menu.visible = false
	if meta_menu: meta_menu.visible = false
	if pause_menu: pause_menu.visible = false
	if settings_menu: settings_menu.visible = false
	if controls_screen: controls_screen.visible = false
	if credits_screen: credits_screen.visible = false


func _on_game_state_changed(new_state, _prev_state):
	var gm = get_node("/root/GameManager")
	if not gm:
		return
	match new_state:
		gm.GameState.MENU:
			_show_menu()
		gm.GameState.PLAYING:
			start_game()
		gm.GameState.PAUSED:
			if pause_menu:
				pause_menu.visible = true
		gm.GameState.GAME_OVER:
			_on_game_over()
		gm.GameState.META:
			_show_meta()


func _show_menu():
	_game_started = false
	_clear_world()
	_hide_all_menus()
	if hud:
		hud.visible = false
	if main_menu:
		main_menu.visible = true
	if parallax:
		parallax.visible = true
	if player:
		player.visible = false
		player.process_mode = Node.PROCESS_MODE_DISABLED


func _show_meta():
	_hide_all_menus()
	if meta_menu:
		meta_menu.visible = true
	if parallax:
		parallax.visible = true
	if player:
		player.visible = false
		player.process_mode = Node.PROCESS_MODE_DISABLED


func _clear_world():
	for child in game_world.get_children():
		if child != player and child != $GameWorld/Camera and \
		   child != $GameWorld/WorldEnvironment and child != $GameWorld/CollisionBoundary:
			child.queue_free()


func start_game():
	_game_started = true
	_clear_world()
	_hide_all_menus()
	var transition = $ScreenTransition
	if transition:
		await transition.fade_in(0.2)
	if player:
		player._load_modifiers()
		player.visible = true
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player._reset_state()
		var gm = get_node("/root/GameManager")
		var mode_lives = Constants.MODE_LIVES[gm.game_mode]
		var mods = gm.get_save_modifiers()
		var total_hp_bonus = mods.hp_bonus + mods.hp
		player.max_health = mode_lives + total_hp_bonus
		if player.health > player.max_health:
			player.health = player.max_health
		player.position = Vector2(Constants.VIEWPORT_WIDTH * 0.5, Constants.VIEWPORT_HEIGHT - 100)
		get_node("/root/EventBus").player_respawned.emit()
	if hud:
		hud.visible = true
	if parallax:
		parallax.visible = true
	var wave_manager = get_node("/root/WaveManager")
	if wave_manager:
		wave_manager.start_waves()
	if transition:
		transition.fade_out(0.3)


func _on_game_over():
	_hide_all_menus()
	if hud and hud.get_node_or_null("GameOverScreen"):
		hud.get_node("GameOverScreen").visible = true
		var score_manager = get_node("/root/ScoreManager")
		if score_manager:
			hud.get_node("GameOverScreen/FinalScore").text = "SCORE: %07d" % score_manager.score
			hud.get_node("GameOverScreen/HighScore").text = "HIGH SCORE: %07d" % score_manager.high_score


func _on_player_died(_position):
	var game_manager = get_node("/root/GameManager")
	if player and game_manager:
		if player.health <= 0:
			get_node("/root/WaveManager").stop_waves()
			game_manager.on_run_end()
			await get_tree().create_timer(1.0).timeout
			game_manager.change_state(game_manager.GameState.GAME_OVER)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		var gm = get_node("/root/GameManager")
		if not gm:
			return
		if gm.current_state == gm.GameState.GAME_OVER:
			gm.change_state(gm.GameState.MENU)
	if event.is_action_pressed("ui_cancel"):
		var gm = get_node("/root/GameManager")
		if not gm:
			return
		if gm.current_state == gm.GameState.META:
			gm.change_state(gm.GameState.MENU)
		elif gm.current_state == gm.GameState.PLAYING:
			gm.change_state(gm.GameState.PAUSED)
		elif gm.current_state == gm.GameState.PAUSED:
			gm.change_state(gm.GameState.PLAYING)
