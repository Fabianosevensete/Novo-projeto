extends Node

const Constants = preload("res://scripts/utils/Constants.gd")

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, META }

var current_state := GameState.MENU
var previous_state := GameState.MENU
var player_ref: Node = null
var main_scene: Node = null
var run_credits := 0
var run_kills := 0
var game_mode := Constants.GameMode.ARCADE


func set_mode(mode: int):
	game_mode = mode

@onready var event_bus := get_node("/root/EventBus")


func _ready():
	if not event_bus:
		return
	event_bus.enemy_killed.connect(_on_enemy_killed)
	event_bus.wave_cleared.connect(_on_wave_cleared)
	event_bus.boss_died.connect(_on_boss_died)


func _on_enemy_killed(_type, _pos, _score):
	run_credits += Constants.MEGA_CREDITS_PER_KILL
	run_kills += 1


func _on_wave_cleared(_wave):
	run_credits += Constants.MEGA_CREDITS_WAVE_BONUS


func _on_boss_died(_pos):
	run_credits += Constants.MEGA_CREDITS_PER_BOSS


func change_state(new_state: GameState):
	if new_state == current_state:
		return
	previous_state = current_state
	current_state = new_state
	var tree := get_tree()
	if tree and not OS.has_feature("headless"):
		tree.paused = (current_state == GameState.PAUSED)
	if event_bus:
		event_bus.game_state_changed.emit(new_state, previous_state)


func is_playing() -> bool:
	return current_state == GameState.PLAYING


func is_paused() -> bool:
	return current_state == GameState.PAUSED


func get_save_modifiers() -> Dictionary:
	var save = get_node("/root/SaveManager")
	var ship = save.selected_ship
	var mods = Constants.SHIP_MODIFIERS[ship].duplicate()
	mods.hp_bonus = save.get_upgrade_level(Constants.UpgradeType.MAX_HP)
	mods.speed_mult = 1.0 + save.get_upgrade_level(Constants.UpgradeType.SPEED) * 0.05
	mods.fire_rate_mult = 1.0 + save.get_upgrade_level(Constants.UpgradeType.FIRE_RATE) * 0.05
	mods.dash_cd_bonus = save.get_upgrade_level(Constants.UpgradeType.DASH_CD) * 0.2
	mods.shield_dur_bonus = save.get_upgrade_level(Constants.UpgradeType.SHIELD_DUR) * 0.5
	mods.score_mult = 1.0 + save.get_upgrade_level(Constants.UpgradeType.SCORE_MULT) * 0.1
	mods.start_weapon = save.get_upgrade_level(Constants.UpgradeType.START_WEAPON)
	return mods


func on_run_end():
	var save = get_node("/root/SaveManager")
	save.add_credits(run_credits)
	save.total_runs += 1
	save.total_kills += run_kills
	var total_score = 0
	if has_node("/root/ScoreManager"):
		total_score = get_node("/root/ScoreManager").get_total_score()
	if total_score > save.high_score:
		save.high_score = total_score
	save.save_data()
	run_credits = 0
	run_kills = 0
