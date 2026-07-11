extends Node

const Constants = preload("res://scripts/utils/Constants.gd")

var credits := Constants.STARTING_CREDITS
var selected_ship := Constants.ShipType.INTERCEPTOR
var unlocked_ships := [true, false, false, false, false]
var upgrades := {}
var high_score := 0
var total_runs := 0
var total_kills := 0
var sfx_volume := 0.0
var music_volume := 0.0


func _ready():
	load_data()


func load_data():
	var cfg = ConfigFile.new()
	if cfg.load(Constants.SAVE_PATH) != OK:
		reset_data()
		return
	credits = cfg.get_value("meta", "credits", Constants.STARTING_CREDITS)
	selected_ship = cfg.get_value("meta", "selected_ship", Constants.ShipType.INTERCEPTOR)
	high_score = cfg.get_value("meta", "high_score", 0)
	total_runs = cfg.get_value("meta", "total_runs", 0)
	total_kills = cfg.get_value("meta", "total_kills", 0)
	var unlocks = cfg.get_value("ships", "unlocked", "true,false,false,false,false")
	var parts = unlocks.split(",")
	unlocked_ships = []
	for p in parts:
		unlocked_ships.append(p == "true")
	for i in range(Constants.UPGRADE_COUNT):
		var key = "upgrade_" + str(i)
		upgrades[i] = cfg.get_value("upgrades", key, 0)
	sfx_volume = cfg.get_value("settings", "sfx_volume", 0.0)
	music_volume = cfg.get_value("settings", "music_volume", 0.0)
	ensure_defaults()


func save_data():
	var cfg = ConfigFile.new()
	cfg.set_value("meta", "credits", credits)
	cfg.set_value("meta", "selected_ship", selected_ship)
	var current_score = 0
	if is_inside_tree():
		var sm = get_node_or_null("/root/ScoreManager")
		if sm:
			current_score = sm.get_total_score()
	cfg.set_value("meta", "high_score", max(high_score, current_score))
	cfg.set_value("meta", "total_runs", total_runs)
	cfg.set_value("meta", "total_kills", total_kills)
	var parts = []
	for u in unlocked_ships:
		parts.append("true" if u else "false")
	cfg.set_value("ships", "unlocked", ",".join(parts))
	for i in range(Constants.UPGRADE_COUNT):
		cfg.set_value("upgrades", "upgrade_" + str(i), upgrades.get(i, 0))
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.save(Constants.SAVE_PATH)


func reset_data():
	credits = Constants.STARTING_CREDITS
	selected_ship = Constants.ShipType.INTERCEPTOR
	unlocked_ships = [true, false, false, false, false, false, false, false]
	unlocked_ships.resize(Constants.SHIP_COUNT)
	upgrades = {}
	high_score = 0
	total_runs = 0
	total_kills = 0
	save_data()


func has_upgrade(upgrade_type: int) -> bool:
	return upgrades.get(upgrade_type, 0) > 0


func get_upgrade_level(upgrade_type: int) -> int:
	return upgrades.get(upgrade_type, 0)


func add_credits(amount: int):
	credits += amount


func spend_credits(amount: int) -> bool:
	if credits >= amount:
		credits -= amount
		return true
	return false


func buy_upgrade(upgrade_type: int) -> bool:
	var current_level = get_upgrade_level(upgrade_type)
	if current_level >= Constants.UPGRADE_MAX_LEVEL:
		return false
	var cost = Constants.UPGRADE_COSTS[upgrade_type][current_level]
	if not spend_credits(cost):
		return false
	upgrades[upgrade_type] = current_level + 1
	save_data()
	return true


func buy_ship(ship_type: int) -> bool:
	if ship_type < 0 or ship_type >= Constants.SHIP_COUNT:
		return false
	if unlocked_ships[ship_type]:
		return false
	if not spend_credits(Constants.SHIP_COSTS[ship_type]):
		return false
	unlocked_ships[ship_type] = true
	save_data()
	return true


func select_ship(ship_type: int):
	if ship_type >= 0 and ship_type < Constants.SHIP_COUNT and unlocked_ships[ship_type]:
		selected_ship = ship_type
		save_data()


func ensure_defaults():
	for i in range(Constants.UPGRADE_COUNT):
		if not upgrades.has(i):
			upgrades[i] = 0
	unlocked_ships.resize(Constants.SHIP_COUNT)
	for i in range(Constants.SHIP_COUNT):
		if i >= unlocked_ships.size():
			unlocked_ships.append(false)
	unlocked_ships[0] = true
