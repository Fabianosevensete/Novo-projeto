class_name Pickup
extends Area2D

const Constants = preload("res://scripts/utils/Constants.gd")

@export var pickup_type := Constants.PickupType.HEALTH

var _lifetime := Constants.PICKUP_LIFETIME
var _time := 0.0
var _initial_y := 0.0

@onready var sprite := $Sprite2D
@onready var collision_shape := $CollisionShape2D
@onready var label := $Label


func _ready():
	add_to_group(Constants.GROUPS.PICKUP)
	area_entered.connect(_on_area_entered)
	_generate_texture()
	_initial_y = position.y


func _generate_texture():
	if not sprite:
		return
	var color := _get_color()
	var char_label := _get_char()
	var image = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for x in range(20):
		for y in range(20):
			var dx = x - 10
			var dy = y - 10
			var dist = sqrt(dx*dx + dy*dy)
			if dist <= 9:
				var alpha = 1.0
				if dist > 7:
					alpha = 1.0 - (dist - 7) * 0.5
				var c = color
				c.a = alpha
				image.set_pixel(x, y, c)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	if label:
		label.text = char_label


func _get_color() -> Color:
	match pickup_type:
		Constants.PickupType.HEALTH: return Color(0.2, 1.0, 0.2, 1.0)
		Constants.PickupType.SHIELD: return Color(0.2, 0.5, 1.0, 1.0)
		Constants.PickupType.WEAPON_UP: return Color(1.0, 0.5, 0.0, 1.0)
		Constants.PickupType.SCORE_MULTI: return Color(1.0, 1.0, 0.0, 1.0)
		Constants.PickupType.SPEED_BOOST: return Color(0.0, 1.0, 1.0, 1.0)
	return Color.WHITE


func _get_char() -> String:
	match pickup_type:
		Constants.PickupType.HEALTH: return "+"
		Constants.PickupType.SHIELD: return "S"
		Constants.PickupType.WEAPON_UP: return "W"
		Constants.PickupType.SCORE_MULTI: return "x2"
		Constants.PickupType.SPEED_BOOST: return ">>"
	return "?"


func _process(delta):
	_time += delta
	_lifetime -= delta
	position.y += Constants.PICKUP_FALL_SPEED * delta
	var pulse = 1.0 + sin(_time * Constants.PICKUP_PULSE_SPEED) * 0.15
	sprite.scale = Vector2(pulse, pulse)
	if _lifetime <= 0:
		_despawn()
	_check_out_of_bounds()


func _despawn():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


func _check_out_of_bounds():
	var viewport = get_viewport()
	var view_size = viewport.get_visible_rect().size
	if global_position.y > view_size.y + 100:
		queue_free()


func _on_area_entered(area: Area2D):
	if area.is_in_group(Constants.GROUPS.PLAYER):
		if area.has_method("collect_pickup"):
			area.collect_pickup(pickup_type)
		var event_bus = get_node("/root/EventBus")
		event_bus.pickup_collected.emit(pickup_type, global_position)
		_collect_effect()


func _collect_effect():
	var pickup_names = ["HP", "Shield", "WeaponUp", "x2 Score", "Speed"]
	var name = pickup_names[pickup_type] if pickup_type >= 0 and pickup_type < pickup_names.size() else "Pickup"
	var ft_script = load("res://scripts/effects/FloatingText.gd")
	if ft_script:
		var ft = ft_script.new()
		ft.global_position = global_position
		get_tree().current_scene.add_child(ft)
		ft.show_text(name, global_position, Color(0, 1, 0.5, 1), 14)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.15)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
