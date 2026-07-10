extends Node

const SoundGenerator = preload("res://scripts/utils/SoundGenerator.gd")
const MusicGenerator = preload("res://scripts/utils/MusicGenerator.gd")

var sfx_players := []
var music_player: AudioStreamPlayer = null
var event_bus: EventBus
var game_manager: GameManager
var sound_cache := {}

func _ready():
	for i in range(12):
		var p = AudioStreamPlayer2D.new()
		add_child(p)
		sfx_players.append(p)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	_generate_sounds()
	_connect_signals()
	var save = get_node("/root/SaveManager")
	set_sfx_volume(save.sfx_volume)
	set_music_volume(save.music_volume)


func _generate_sounds():
	sound_cache["shoot"] = SoundGenerator.generate_shoot()
	sound_cache["explosion"] = SoundGenerator.generate_explosion()
	sound_cache["hit"] = SoundGenerator.generate_hit()
	sound_cache["pickup"] = SoundGenerator.generate_pickup()
	sound_cache["dash"] = SoundGenerator.generate_dash()
	sound_cache["boss_warning"] = SoundGenerator.generate_boss_warning()
	sound_cache["boss_explosion"] = SoundGenerator.generate_boss_explosion()
	sound_cache["weapon_switch"] = SoundGenerator.generate_weapon_switch()
	sound_cache["wave_start"] = SoundGenerator.generate_wave_start()
	sound_cache["powerup_activate"] = SoundGenerator.generate_powerup_activate()


func _connect_signals():
	event_bus = get_node("/root/EventBus")
	game_manager = get_node("/root/GameManager")
	event_bus.bullet_fired.connect(_on_bullet_fired)
	event_bus.player_damaged.connect(_on_player_damaged)
	event_bus.player_died.connect(_on_player_died)
	event_bus.enemy_killed.connect(_on_enemy_killed)
	event_bus.player_dashed.connect(_on_player_dashed)
	event_bus.pickup_collected.connect(_on_pickup_collected)
	event_bus.power_up_activated.connect(_on_power_up_activated)
	event_bus.weapon_changed.connect(_on_weapon_changed)
	event_bus.wave_started.connect(_on_wave_started)
	event_bus.wave_cleared.connect(_on_wave_cleared)
	event_bus.boss_spawned.connect(_on_boss_spawned)
	event_bus.boss_died.connect(_on_boss_died)
	event_bus.game_state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: int, _previous_state: int):
	if new_state == game_manager.GameState.PLAYING:
		var music = MusicGenerator.generate_battle_music(16.0)
		play_music(music)
	elif new_state == game_manager.GameState.GAME_OVER or new_state == game_manager.GameState.MENU:
		stop_music()


func _on_bullet_fired(_bullet, position, _direction):
	play_sfx("shoot", position, 0.15)


func _on_player_damaged(_amount, position):
	play_sfx("hit", position, 0.1)


func _on_player_died(position):
	play_sfx("explosion", position, 0.0)


func _on_enemy_killed(_enemy_type, position, _score):
	play_sfx("explosion", position, 0.15)


func _on_player_dashed():
	play_sfx("dash", Vector2.ZERO, 0.05)


func _on_pickup_collected(_pickup_type, position):
	play_sfx("pickup", position, 0.1)


func _on_power_up_activated(_pickup_type, _duration):
	play_sfx("powerup_activate", Vector2.ZERO, 0.05)


func _on_weapon_changed(_index, _name):
	play_sfx("weapon_switch", Vector2.ZERO, 0.05)


func _on_wave_started(_wave):
	play_sfx("wave_start", Vector2.ZERO, 0.0)


func _on_wave_cleared(_wave):
	play_sfx("wave_start", Vector2.ZERO, 0.05)


func _on_boss_spawned(_boss):
	play_sfx("boss_warning", Vector2.ZERO, 0.0)
	var music = MusicGenerator.generate_boss_music(16.0)
	play_music(music)


func _on_boss_died(position):
	play_sfx("boss_explosion", position, 0.0)
	var music = MusicGenerator.generate_battle_music(16.0)
	play_music(music)


func play_sfx(sound_name: String, position: Vector2 = Vector2.ZERO, pitch_variation: float = 0.1):
	if not sound_cache.has(sound_name):
		return
	for p in sfx_players:
		if not p.playing:
			p.stream = sound_cache[sound_name]
			p.global_position = position
			p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			p.volume_db = -3.0
			p.play()
			return


func play_music(stream: AudioStream, loop: bool = true):
	music_player.stream = stream
	music_player.play()


func stop_music(fade_out: float = 0.0):
	music_player.stop()


func set_music_volume(db: float):
	music_player.volume_db = db


func set_sfx_volume(db: float):
	for p in sfx_players:
		p.volume_db = db
