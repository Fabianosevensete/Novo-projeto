class_name Bullet
extends Area2D

var direction := Vector2.UP
@export var speed := 800.0
@export var damage := 1
@export var is_player_bullet := true
@export var bullet_type := 0
var life_timer := 3.0
var _has_hit := false

const Constants = preload("res://scripts/utils/Constants.gd")


func _ready():
	if is_player_bullet:
		add_to_group(Constants.GROUPS.PLAYER_BULLET)
	else:
		add_to_group(Constants.GROUPS.ENEMY_BULLET)
	area_entered.connect(_on_area_entered)
	_generate_texture()


func _generate_texture():
	var sprite = $Sprite2D as Sprite2D
	if not sprite:
		return
	var w = 8
	var h = 16
	var color := _get_color()
	if bullet_type == Constants.WeaponType.PLASMA:
		w = 20; h = 20
	elif bullet_type == Constants.WeaponType.MISSILE:
		w = 10; h = 20
	elif bullet_type == Constants.WeaponType.SHOTGUN:
		w = 4; h = 8
	var image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_bullet(image, w, h, color)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	var shape = $CollisionShape2D.shape as RectangleShape2D
	if shape:
		shape.size = Vector2(w * 0.8, h * 0.8)


func _get_color() -> Color:
	match bullet_type:
		Constants.WeaponType.BASIC: return Color(0, 1, 1, 1)
		Constants.WeaponType.LASER: return Color(0.3, 1.0, 0.5, 1)
		Constants.WeaponType.PLASMA: return Color(1.0, 0.5, 0.0, 1)
		Constants.WeaponType.MISSILE: return Color(1.0, 0.2, 0.2, 1)
		Constants.WeaponType.SHOTGUN: return Color(1.0, 1.0, 0.3, 1)
	return Color.WHITE


func _draw_bullet(image: Image, w: int, h: int, color: Color):
	match bullet_type:
		Constants.WeaponType.LASER:
			for x in range(w):
				for y in range(h):
					if abs(x - w/2) <= 1:
						var alpha = 1.0 if y < h * 0.8 else 0.5
						var c = color
						c.a = alpha
						image.set_pixel(x, y, c)
		Constants.WeaponType.PLASMA:
			var cx = w / 2.0; var cy = h / 2.0
			for x in range(w):
				for y in range(h):
					var dx = x - cx; var dy = y - cy
					var dist = sqrt(dx*dx + dy*dy)
					if dist <= w * 0.45:
						var alpha = 1.0 - dist / (w * 0.45)
						var c = color
						c.a = alpha * 0.8
						image.set_pixel(x, y, c)
		Constants.WeaponType.MISSILE:
			for x in range(w):
				for y in range(h):
					var dx = abs(x - w/2)
					var dy = y
					if dx <= 1:
						image.set_pixel(x, y, color)
					if dy > h * 0.6 and dx <= 2:
						var c = Color(1, 0.5, 0, 1)
						c.a = 1.0 - (dy - h*0.6) / (h*0.4)
						image.set_pixel(x, y, c)
		_:
			for x in range(w):
				for y in range(h):
					var dx = abs(x - w/2)
					if dx <= 1 and y < h - 1:
						image.set_pixel(x, y, color)
					if y == h - 1 and dx <= 2:
						var c = color * 1.5
						c.a = 0.7
						image.set_pixel(x, y, c)


func set_direction(dir: Vector2):
	direction = dir


func _process(delta):
	if bullet_type == Constants.WeaponType.MISSILE:
		_homing_update(delta)
	global_position += direction * speed * delta
	life_timer -= delta
	if life_timer <= 0:
		queue_free()
	_check_out_of_bounds()


func _homing_update(delta):
	var target = _find_nearest_enemy()
	if target:
		var target_dir = (target.global_position - global_position).normalized()
		direction = direction.lerp(target_dir, Constants.MISSILE_HOMING_STRENGTH * delta).normalized()
		rotation = direction.angle()


func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group(Constants.GROUPS.ENEMY)
	var nearest: Node2D = null
	var min_dist := INF
	for enemy in enemies:
		var e = enemy as Node2D
		if e and is_instance_valid(e):
			var d = global_position.distance_squared_to(e.global_position)
			if d < min_dist:
				min_dist = d
				nearest = e
	return nearest


func _check_out_of_bounds():
	var viewport = get_viewport()
	var view_size = viewport.get_visible_rect().size
	var margin = 100.0
	if global_position.x < -margin or global_position.x > view_size.x + margin or \
	   global_position.y < -margin or global_position.y > view_size.y + margin:
		queue_free()


func _on_area_entered(area: Area2D):
	if _has_hit:
		return
	if is_player_bullet and area.is_in_group(Constants.GROUPS.ENEMY):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		_has_hit = true
		if bullet_type == Constants.WeaponType.PLASMA:
			_plasma_aoe(area.global_position)
		queue_free()
	elif not is_player_bullet and area.is_in_group(Constants.GROUPS.PLAYER):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		_has_hit = true
		queue_free()


func _plasma_aoe(pos: Vector2):
	var enemies = get_tree().get_nodes_in_group(Constants.GROUPS.ENEMY)
	for enemy in enemies:
		var e = enemy as Node2D
		if e and is_instance_valid(e):
			if e.global_position.distance_to(pos) <= 60.0:
				if e.has_method("take_damage"):
					e.take_damage(1)
