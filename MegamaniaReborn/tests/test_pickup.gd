extends GutTest

const Constants = preload("res://scripts/utils/Constants.gd")


func before_all():
	if not get_tree().root.has_node("EventBus"):
		var eb = load("res://scripts/core/EventBus.gd").new()
		get_tree().root.add_child(eb)
		eb.name = "EventBus"


func test_default_type_is_health():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	assert_eq(pickup.pickup_type, Constants.PickupType.HEALTH, "Default type should be HEALTH")


func test_set_pickup_type():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	pickup.pickup_type = Constants.PickupType.SHIELD
	assert_eq(pickup.pickup_type, Constants.PickupType.SHIELD, "Type should be SHIELD")


func test_lifetime_decreases():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	var initial = pickup._lifetime
	pickup._lifetime = 5.0
	pickup._process(1.0)
	assert_eq(pickup._lifetime, 4.0, "Lifetime should decrease by delta")


func test_get_color_health():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	pickup.pickup_type = Constants.PickupType.HEALTH
	assert_eq(pickup._get_color(), Color(0.2, 1.0, 0.2, 1.0), "Health color should be green")


func test_get_color_shield():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	pickup.pickup_type = Constants.PickupType.SHIELD
	assert_eq(pickup._get_color(), Color(0.2, 0.5, 1.0, 1.0), "Shield color should be blue")


func test_get_color_weapon_up():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	pickup.pickup_type = Constants.PickupType.WEAPON_UP
	assert_eq(pickup._get_color(), Color(1.0, 0.5, 0.0, 1.0), "WeaponUp color should be orange")


func test_get_char_health():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	pickup.pickup_type = Constants.PickupType.HEALTH
	assert_eq(pickup._get_char(), "+", "Health char should be +")


func test_get_char_shield():
	var pickup = autofree(load("res://scripts/core/Pickup.gd").new())
	pickup.pickup_type = Constants.PickupType.SHIELD
	assert_eq(pickup._get_char(), "S", "Shield char should be S")
