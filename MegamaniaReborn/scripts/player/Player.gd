class_name Player
extends Area2D

const Constants = preload("res://scripts/utils/Constants.gd")

var health := Constants.PLAYER_MAX_HEALTH
var max_health := Constants.PLAYER_MAX_HEALTH
var invulnerable := false
var can_shoot := true
var can_dash := true
var dashing := false
var velocity := Vector2.ZERO
var shoot_cooldown_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_timer := 0.0
var invulnerability_timer := 0.0
var screen_size := Vector2.ZERO
var _texture_generated := false

var _shield_timer := 0.0
var _weapon_up_timer := 0.0
var _score_multi_timer := 0.0
var _speed_boost_timer := 0.0
var _base_speed_mult := 1.0
var _effective_speed_mult := 1.0
var _current_cooldown_mult := 1.0
var _shield_orb: Node2D = null

var current_weapon := 0

var _ship_speed_mult := 1.0
var _ship_damage_mult := 1.0
var _ship_fire_rate_mult := 1.0
var _ship_dash_cd_bonus := 0.0
var _ship_start_pickup := -1
var _hp_bonus := 0
var _upgrade_speed_mult := 1.0
var _upgrade_fire_rate_mult := 1.0
var _upgrade_dash_cd_bonus := 0.0
var _upgrade_shield_dur_bonus := 0.0
var _start_weapon := 0

@onready var sprite := $Sprite2D
@onready var shoot_point := $ShootPoint
@onready var dash_cooldown_ui := $DashCooldown
@onready var trail := $Trail
@onready var collision_shape := $CollisionShape2D
@onready var event_bus := get_node("/root/EventBus")


func _ready():
	screen_size = get_viewport().get_visible_rect().size
	add_to_group(Constants.GROUPS.PLAYER)
	area_entered.connect(_on_area_entered)
	if event_bus:
		event_bus.player_respawned.connect(_on_respawn)
	_generate_texture()
	_create_shield_orb()
	_load_modifiers()
	_reset_state()


func _load_modifiers():
	var gm = get_node("/root/GameManager")
	var mods = gm.get_save_modifiers()
	_ship_speed_mult = mods.speed
	_ship_damage_mult = mods.damage
	_ship_fire_rate_mult = mods.fire_rate
	_ship_dash_cd_bonus = mods.dash_cd
	_ship_start_pickup = mods.start_pickup
	_hp_bonus = mods.hp_bonus + mods.hp
	_upgrade_speed_mult = mods.speed_mult
	_upgrade_fire_rate_mult = mods.fire_rate_mult
	_upgrade_dash_cd_bonus = mods.dash_cd_bonus
	_upgrade_shield_dur_bonus = mods.shield_dur_bonus
	_start_weapon = mods.start_weapon


func _generate_texture():
	var img_size = 48
	var image = Image.create(img_size, img_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var cx = img_size / 2
	for x in range(img_size):
		for y in range(img_size):
			var dx = x - cx
			var dy = y - cx
			var col = _ship_pixel(dx, dy)
			if col.a > 0:
				image.set_pixel(x, y, col)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	_texture_generated = true


func _body_hw(dy: int) -> int:
	if dy < -22 or dy > 14:
		return 0
	if dy <= -12:
		return maxi(0, roundi((-dy - 23.0) * 0.55))
	if dy <= 6:
		return 6
	if dy <= 12:
		return maxi(2, 7 - roundi((dy - 6) * 0.7))
	return 2


func _in_right_wing(dx: int, dy: int) -> bool:
	if dy < -6 or dy > 8 or dx < 5:
		return false
	var outer := 0.0
	var inner := 0.0
	if dy <= 2:
		outer = 7.0 + 1.375 * (dy + 6.0)
		inner = 7.0 - 0.1 * (dy + 6.0)
	elif dy <= 4:
		outer = 18.0 - 0.5 * (dy - 2.0)
		inner = 7.0 - 0.1 * (dy + 6.0)
	else:
		outer = 18.0 - 0.5 * (dy - 2.0)
		inner = 6.0 + 2.25 * (dy - 4.0)
	var bhw = _body_hw(dy)
	return dx >= maxf(inner, bhw + 1.0) and dx <= outer


func _ship_pixel(dx: int, dy: int) -> Color:
	var abs_dx = abs(dx)
	var bhw = _body_hw(dy)

	# Engine glow
	if bhw <= 0 and dy >= 10 and dy <= 20 and abs_dx <= 2:
		var fade = 1.0 - (dy - 10.0) / 10.0
		return Color(1.0, 0.5, 0.05, fade * 0.35)

	# Engine ports
	if dy >= 10 and dy <= 13 and abs_dx >= 1 and abs_dx <= 2:
		var t = (dy - 10.0) / 3.0
		return Color(1.0, 0.55 - t * 0.35, 0.1, 1.0)

	# Body (fuselage)
	if bhw > 0 and abs_dx <= bhw:
		if dy >= -22 and dy <= -12:
			var t = (dy + 22.0) / 10.0
			return Color(0.08 + t * 0.12, 0.15 + t * 0.15, 0.32 + t * 0.15, 1.0)
		if dy <= 6:
			var highlight = 0.0
			if abs_dx == bhw:
				highlight = 0.15
			elif abs_dx >= bhw - 1:
				highlight = 0.08
			if dy >= -8 and dy <= 0 and dx % 3 == 0 and dy % 4 == 0:
				return Color(0.12, 0.22, 0.38, 1.0)
			return Color(0.15 + highlight, 0.28 + highlight, 0.45 + highlight * 0.5, 1.0)
		if dy <= 12:
			var t = (dy - 6.0) / 6.0
			return Color(0.15 - t * 0.05, 0.28 - t * 0.08, 0.45 - t * 0.12, 1.0)
		if dy <= 14:
			return Color(0.12, 0.18, 0.28, 1.0)

	# Cockpit
	if bhw > 0 and abs_dx <= 2 and dy >= -12 and dy <= -6:
		if dy == -9 and dx == 0:
			return Color(1.0, 1.0, 1.0, 1.0)
		return Color(0.35, 0.75, 1.0, 1.0)

	# Wings
	if dx < 0:
		if _in_right_wing(-dx, dy):
			var adx = -dx
			if adx >= 14:
				return Color(0.55, 0.08, 0.08, 1.0)
			if adx >= 12:
				return Color(0.4, 0.12, 0.1, 1.0)
			if adx >= bhw + 1 and adx <= bhw + 2:
				return Color(0.22, 0.38, 0.55, 1.0)
			return Color(0.14, 0.24, 0.38, 1.0)
	elif dx > 0:
		if _in_right_wing(dx, dy):
			if dx >= 14:
				return Color(0.55, 0.08, 0.08, 1.0)
			if dx >= 12:
				return Color(0.4, 0.12, 0.1, 1.0)
			if dx >= bhw + 1 and dx <= bhw + 2:
				return Color(0.22, 0.38, 0.55, 1.0)
			return Color(0.14, 0.24, 0.38, 1.0)

	return Color.TRANSPARENT


func _create_shield_orb():
	_shield_orb = Node2D.new()
	_shield_orb.name = "ShieldOrb"
	add_child(_shield_orb)
	var orb_sprite = Sprite2D.new()
	orb_sprite.name = "OrbSprite"
	var orb_image = Image.create(40, 40, false, Image.FORMAT_RGBA8)
	orb_image.fill(Color(0, 0, 0, 0))
	var blue = Color(0.2, 0.5, 1.0, 0.4)
	for x in range(40):
		for y in range(40):
			var dx = x - 20
			var dy = y - 20
			var dist = sqrt(dx*dx + dy*dy)
			if dist >= 16 and dist <= 20:
				var alpha = 0.5 - abs(dist - 18) * 0.1
				var c = blue
				c.a = max(0, alpha)
				orb_image.set_pixel(x, y, c)
	var orb_texture = ImageTexture.create_from_image(orb_image)
	orb_sprite.texture = orb_texture
	_shield_orb.add_child(orb_sprite)
	_shield_orb.visible = false


func _reset_state():
	max_health = Constants.PLAYER_MAX_HEALTH + _hp_bonus
	health = max_health
	current_weapon = _start_weapon
	invulnerable = false
	can_shoot = true
	can_dash = true
	dashing = false
	velocity = Vector2.ZERO
	shoot_cooldown_timer = 0.0
	dash_cooldown_timer = 0.0
	dash_timer = 0.0
	invulnerability_timer = 0.0
	_shield_timer = 0.0
	_weapon_up_timer = 0.0
	_score_multi_timer = 0.0
	_speed_boost_timer = 0.0
	_base_speed_mult = _ship_speed_mult * _upgrade_speed_mult
	_effective_speed_mult = _base_speed_mult
	_current_cooldown_mult = 1.0
	if _ship_start_pickup >= 0:
		collect_pickup(_ship_start_pickup)
	if _shield_orb:
		_shield_orb.visible = false
	var score_manager = get_node("/root/ScoreManager")
	if score_manager:
		score_manager.score_multiplier = 1
	event_bus.weapon_changed.emit(current_weapon, Constants.WEAPON_NAMES[current_weapon])
	position = screen_size * 0.5
	visible = true
	modulate = Color.WHITE
	if collision_shape:
		collision_shape.set_deferred("disabled", false)


func _process(delta):
	_update_timers(delta)
	_handle_weapon_switch()
	if not dashing:
		_handle_movement(delta)
	_handle_shoot(delta)
	_handle_dash()
	_update_sprite()
	_clamp_position()


func _update_timers(delta):
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= delta * _current_cooldown_mult
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false
	if invulnerable and _shield_timer <= 0:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0:
			invulnerable = false
			modulate = Color.WHITE
			sprite.visible = true
		else:
			sprite.visible = int(invulnerability_timer * 10) % 2 == 0
	if _shield_timer > 0:
		_shield_timer -= delta
		invulnerable = true
		if _shield_orb:
			_shield_orb.visible = true
			_shield_orb.rotation += delta * 2.0
		if _shield_timer <= 0:
			_shield_timer = 0.0
			if _shield_orb:
				_shield_orb.visible = false
			if invulnerability_timer <= 0:
				invulnerable = false
			event_bus.power_up_deactivated.emit(Constants.PickupType.SHIELD)
	if _weapon_up_timer > 0:
		_weapon_up_timer -= delta
		_current_cooldown_mult = Constants.WEAPON_UP_COOLDOWN_MULT
		if _weapon_up_timer <= 0:
			_weapon_up_timer = 0.0
			_current_cooldown_mult = 1.0
			event_bus.power_up_deactivated.emit(Constants.PickupType.WEAPON_UP)
	if _score_multi_timer > 0:
		_score_multi_timer -= delta
		if _score_multi_timer <= 0:
			_score_multi_timer = 0.0
			var score_manager = get_node("/root/ScoreManager")
			if score_manager:
				score_manager.score_multiplier = 1
			event_bus.power_up_deactivated.emit(Constants.PickupType.SCORE_MULTI)
	if _speed_boost_timer > 0:
		_speed_boost_timer -= delta
		_effective_speed_mult = _base_speed_mult * Constants.SPEED_BOOST_MULT
		if _speed_boost_timer <= 0:
			_speed_boost_timer = 0.0
			_effective_speed_mult = _base_speed_mult
			event_bus.power_up_deactivated.emit(Constants.PickupType.SPEED_BOOST)


func _handle_movement(delta):
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()
	var target_velocity = input_dir * Constants.PLAYER_SPEED * _effective_speed_mult
	if input_dir == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, Constants.PLAYER_FRICTION * delta)
	else:
		velocity = velocity.move_toward(target_velocity, Constants.PLAYER_ACCELERATION * delta)
	position += velocity * delta
	if trail:
		trail.emitting = input_dir.length() > 0.1


func _handle_weapon_switch():
	var new_weapon := -1
	if Input.is_key_pressed(KEY_1): new_weapon = 0
	elif Input.is_key_pressed(KEY_2): new_weapon = 1
	elif Input.is_key_pressed(KEY_3): new_weapon = 2
	elif Input.is_key_pressed(KEY_4): new_weapon = 3
	elif Input.is_key_pressed(KEY_5): new_weapon = 4
	if new_weapon >= 0 and new_weapon != current_weapon:
		current_weapon = new_weapon
		event_bus.weapon_changed.emit(current_weapon, Constants.WEAPON_NAMES[current_weapon])


func _handle_shoot(delta):
	if Input.is_action_pressed("shoot") and can_shoot and shoot_cooldown_timer <= 0:
		_fire_weapon()
		var fire_rate_mult = _ship_fire_rate_mult * _upgrade_fire_rate_mult
		shoot_cooldown_timer = Constants.WEAPON_COOLDOWNS[current_weapon] / fire_rate_mult


func _handle_dash():
	if Input.is_action_just_pressed("dash") and can_dash and not dashing:
		_perform_dash()


func _perform_dash():
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	if input_dir == Vector2.ZERO:
		input_dir = Vector2.RIGHT
	input_dir = input_dir.normalized()
	dashing = true
	can_dash = false
	dash_timer = Constants.PLAYER_DASH_DURATION
	dash_cooldown_timer = max(0.1, Constants.PLAYER_DASH_COOLDOWN + _ship_dash_cd_bonus - _upgrade_dash_cd_bonus)
	velocity = input_dir * Constants.PLAYER_DASH_SPEED
	invulnerable = true
	invulnerability_timer = Constants.PLAYER_DASH_DURATION + 0.1
	if event_bus:
		event_bus.player_dashed.emit()


func _fire_weapon():
	if current_weapon == Constants.WeaponType.SHOTGUN:
		_fire_shotgun()
		return
	var scene_path = Constants.WEAPON_SCENES[current_weapon]
	var scene = load(scene_path)
	if not scene:
		return
	var bullet = scene.instantiate()
	bullet.global_position = shoot_point.global_position
	bullet.direction = Vector2.UP
	bullet.damage = int(Constants.WEAPON_DAMAGES[current_weapon] * _ship_damage_mult)
	get_tree().current_scene.add_child(bullet)
	event_bus.bullet_fired.emit(bullet, bullet.global_position, Vector2.UP)


func _fire_shotgun():
	var scene = load(Constants.WEAPON_SCENES[Constants.WeaponType.SHOTGUN])
	if not scene:
		return
	var base_dir = Vector2.UP
	for i in range(Constants.SHOTGUM_PELLETS):
		var pellet = scene.instantiate()
		pellet.global_position = shoot_point.global_position
		var spread = randf_range(-Constants.SHOTGUN_SPREAD, Constants.SHOTGUN_SPREAD)
		pellet.direction = base_dir.rotated(spread)
		pellet.damage = int(Constants.WEAPON_DAMAGES[Constants.WeaponType.SHOTGUN] * _ship_damage_mult)
		get_tree().current_scene.add_child(pellet)
		event_bus.bullet_fired.emit(pellet, pellet.global_position, pellet.direction)


func take_damage(amount: int = 1):
	if invulnerable or dashing:
		return
	health -= amount
	invulnerable = true
	invulnerability_timer = Constants.PLAYER_INVULNERABILITY_TIME
	if event_bus:
		event_bus.player_health_changed.emit(health, max_health)
		event_bus.player_damaged.emit(amount, global_position)
		event_bus.screen_shake.emit(Constants.SCREEN_SHAKE_INTENSITY, Constants.SCREEN_SHAKE_DURATION)
	if health <= 0:
		_die()


func collect_pickup(pickup_type: int):
	match pickup_type:
		Constants.PickupType.HEALTH:
			if health < max_health:
				health = min(health + 1, max_health)
				event_bus.player_health_changed.emit(health, max_health)
			else:
				var sm = get_node("/root/ScoreManager")
				if sm:
					sm.add_score(50)
		Constants.PickupType.SHIELD:
			_shield_timer = Constants.SHIELD_DURATION + _upgrade_shield_dur_bonus
			invulnerable = true
			event_bus.power_up_activated.emit(pickup_type, _shield_timer)
		Constants.PickupType.WEAPON_UP:
			_weapon_up_timer = Constants.WEAPON_UP_DURATION
			event_bus.power_up_activated.emit(pickup_type, Constants.WEAPON_UP_DURATION)
		Constants.PickupType.SCORE_MULTI:
			_score_multi_timer = Constants.SCORE_MULTI_DURATION
			var score_manager = get_node("/root/ScoreManager")
			if score_manager:
				score_manager.score_multiplier = Constants.SCORE_MULTI_VALUE
			event_bus.power_up_activated.emit(pickup_type, Constants.SCORE_MULTI_DURATION)
		Constants.PickupType.SPEED_BOOST:
			_speed_boost_timer = Constants.SPEED_BOOST_DURATION
			event_bus.power_up_activated.emit(pickup_type, Constants.SPEED_BOOST_DURATION)


func _die():
	visible = false
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if event_bus:
		event_bus.player_died.emit(global_position)


func _on_respawn():
	_reset_state()


func _update_sprite():
	if _shield_timer > 0:
		sprite.modulate = Color(0.5, 0.8, 1.0, 1.0)
	elif _weapon_up_timer > 0:
		sprite.modulate = Color(1.0, 0.7, 0.2, 1.0)
	elif _speed_boost_timer > 0:
		sprite.modulate = Color(0.0, 1.0, 1.0, 1.0)
	elif dashing:
		sprite.modulate = Color(0.5, 0.8, 1.0, 1.0)
	elif invulnerable:
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.7)
	else:
		sprite.modulate = Color.WHITE


func _clamp_position():
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)


func _on_area_entered(area: Area2D):
	if area.is_in_group(Constants.GROUPS.ENEMY) and not invulnerable:
		take_damage(1)
