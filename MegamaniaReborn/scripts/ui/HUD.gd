extends CanvasLayer

@onready var score_label := $ScoreLabel
@onready var wave_label := $WaveLabel
@onready var lives_container := $LivesContainer
@onready var combo_label := $ComboLabel
@onready var game_over_screen := $GameOverScreen
@onready var powerup_container := $PowerUpContainer
@onready var weapon_label := $WeaponLabel
@onready var boss_hp_bar := $BossHPBar
@onready var boss_hp_label := $BossHPLabel

const Constants = preload("res://scripts/utils/Constants.gd")

var _powerup_labels := {}
var _powerup_timers := {}


func _ready():
	var event_bus = get_node("/root/EventBus")
	event_bus.score_changed.connect(_on_score_changed)
	event_bus.wave_started.connect(_on_wave_started)
	event_bus.combo_updated.connect(_on_combo_updated)
	event_bus.player_damaged.connect(_on_player_damaged)
	event_bus.player_died.connect(_on_player_died)
	event_bus.player_health_changed.connect(_on_player_health_changed)
	event_bus.player_respawned.connect(_on_player_respawned)
	event_bus.game_state_changed.connect(_on_game_state_changed)
	event_bus.power_up_activated.connect(_on_powerup_activated)
	event_bus.power_up_deactivated.connect(_on_powerup_deactivated)
	event_bus.weapon_changed.connect(_on_weapon_changed)
	event_bus.boss_hp_changed.connect(_on_boss_hp_changed)
	event_bus.boss_spawned.connect(_on_boss_spawned)
	event_bus.boss_died.connect(_on_boss_died)
	_show_weapon_name(0, Constants.WEAPON_NAMES[0])
	if boss_hp_bar:
		boss_hp_bar.visible = false
	if boss_hp_label:
		boss_hp_label.visible = false
	if game_over_screen:
		game_over_screen.visible = false
	_update_lives(Constants.PLAYER_MAX_HEALTH)


func _on_boss_spawned(_boss):
	if boss_hp_bar:
		boss_hp_bar.visible = true
		boss_hp_bar.max_value = 100
		boss_hp_bar.value = 100
	if boss_hp_label:
		boss_hp_label.visible = true
		boss_hp_label.text = "??? BOSS ???"


func _on_boss_hp_changed(current_hp: int, max_hp: int):
	if boss_hp_bar:
		boss_hp_bar.max_value = max_hp
		boss_hp_bar.value = current_hp
		var pct = float(current_hp) / float(max_hp)
		if pct > 0.5:
			boss_hp_bar.modulate = Color(0.2, 1.0, 0.2, 1.0)
		elif pct > 0.25:
			boss_hp_bar.modulate = Color(1.0, 1.0, 0.0, 1.0)
		else:
			boss_hp_bar.modulate = Color(1.0, 0.2, 0.2, 1.0)


func _on_boss_died(_pos):
	if boss_hp_bar:
		boss_hp_bar.visible = false
	if boss_hp_label:
		boss_hp_label.visible = false


func _on_weapon_changed(index: int, name_str: String):
	_show_weapon_name(index, name_str)


func _show_weapon_name(index: int, name_str: String):
	if not weapon_label:
		return
	var colors := [Color(0, 1, 1, 1), Color(0.3, 1, 0.5, 1), Color(1, 0.5, 0, 1), Color(1, 0.2, 0.2, 1), Color(1, 1, 0.3, 1)]
	weapon_label.text = "[%d] %s" % [index + 1, name_str]
	weapon_label.add_theme_color_override("font_color", colors[index] if index < colors.size() else Color.WHITE)


func _process(_delta):
	for type in _powerup_timers.keys():
		var remaining = _powerup_timers[type]
		if remaining > 0:
			var label = _powerup_labels.get(type)
			if label:
				var secs = ceil(remaining)
				label.text = _powerup_name(type) + " [" + str(secs) + "s]"


func _powerup_name(type: int) -> String:
	match type:
		Constants.PickupType.SHIELD: return "SHIELD"
		Constants.PickupType.WEAPON_UP: return "WEAPON UP"
		Constants.PickupType.SCORE_MULTI: return "x2 SCORE"
		Constants.PickupType.SPEED_BOOST: return "SPEED"
	return ""


func _powerup_color(type: int) -> Color:
	match type:
		Constants.PickupType.SHIELD: return Color(0.2, 0.5, 1.0, 1.0)
		Constants.PickupType.WEAPON_UP: return Color(1.0, 0.5, 0.0, 1.0)
		Constants.PickupType.SCORE_MULTI: return Color(1.0, 1.0, 0.0, 1.0)
		Constants.PickupType.SPEED_BOOST: return Color(0.0, 1.0, 1.0, 1.0)
	return Color.WHITE


func _on_powerup_activated(type: int, duration: float):
	_powerup_timers[type] = duration
	if type not in _powerup_labels:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", _powerup_color(type))
		label.text = _powerup_name(type)
		powerup_container.add_child(label)
		_powerup_labels[type] = label


func _on_powerup_deactivated(type: int):
	_powerup_timers.erase(type)
	var label = _powerup_labels.get(type)
	if label:
		label.queue_free()
		_powerup_labels.erase(type)


func _on_score_changed(new_score: int, _delta: int):
	score_label.text = "SCORE: %07d" % new_score


func _on_wave_started(wave_number: int):
	wave_label.text = "WAVE %d" % wave_number
	wave_label.scale = Vector2(1.8, 1.8)
	wave_label.modulate = Color(0.0, 1.0, 1.0, 0.0)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave_label, "scale", Vector2(1, 1), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(wave_label, "modulate:a", 1.0, 0.15)
	tween.tween_interval(1.5)
	tween.tween_property(wave_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(wave_label, "scale", Vector2(0.8, 0.8), 0.5)


func _on_combo_updated(combo_count: int):
	if combo_count > 1:
		combo_label.text = "COMBO x%d" % combo_count
		combo_label.visible = true
		combo_label.scale = Vector2(0.5, 0.5)
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.2, 1.2), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.2)
	else:
		combo_label.visible = false


func _on_player_damaged(_amount, _position):
	var flash = $DamageFlash
	if flash:
		flash.modulate = Color(1.0, 0.0, 0.0, 0.4)
		var tween = create_tween()
		tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	_update_lives()


func _on_player_died(_position):
	_update_lives(0)


func _on_player_health_changed(_health: int, _max_hp: int):
	_update_lives()

func _on_player_respawned():
	_update_lives()


func _update_lives(override: int = -1):
	var player = get_tree().get_first_node_in_group(Constants.GROUPS.PLAYER)
	var lives = override if override >= 0 else (player.health if player else 0)
	for i in range(lives_container.get_child_count()):
		var node = lives_container.get_child(i)
		if node is ColorRect:
			node.visible = i < lives


func _on_game_state_changed(new_state, _prev_state):
	var gm = get_node("/root/GameManager")
	if not gm:
		return
	if new_state == gm.GameState.GAME_OVER:
		if game_over_screen:
			game_over_screen.visible = true
			var score_manager = get_node("/root/ScoreManager")
			game_over_screen.get_node("FinalScore").text = "SCORE: %07d" % score_manager.score
			game_over_screen.get_node("HighScore").text = "HIGH SCORE: %07d" % score_manager.high_score
			var credits_label = game_over_screen.get_node_or_null("CreditsEarned")
			if credits_label:
				credits_label.text = "MegaCredits earned: " + str(gm.run_credits)
	else:
		if game_over_screen:
			game_over_screen.visible = false
