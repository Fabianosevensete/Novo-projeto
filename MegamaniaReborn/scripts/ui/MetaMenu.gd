extends Control

const Constants = preload("res://scripts/utils/Constants.gd")

var save_manager: SaveManager
var credits_label: Label
var ship_container: VBoxContainer
var upgrade_container: VBoxContainer
var back_button: Button
var ship_info_label: Label
var reset_button: Button
var ship_scroll: ScrollContainer
var upgrade_scroll: ScrollContainer
var ship_tab: Button
var upgrade_tab: Button

var selected_tab := 0


func _ready():
	save_manager = get_node("/root/SaveManager")
	credits_label = get_node_or_null("CreditsLabel") as Label
	ship_container = get_node_or_null("ShipScroll/ShipContainer") as VBoxContainer
	upgrade_container = get_node_or_null("UpgradeScroll/UpgradeContainer") as VBoxContainer
	back_button = get_node_or_null("BottomBar/BackButton") as Button
	ship_info_label = get_node_or_null("ShipInfoLabel") as Label
	reset_button = get_node_or_null("BottomBar/ResetButton") as Button
	ship_scroll = get_node_or_null("ShipScroll") as ScrollContainer
	upgrade_scroll = get_node_or_null("UpgradeScroll") as ScrollContainer
	ship_tab = get_node_or_null("Tabs/ShipTab") as Button
	upgrade_tab = get_node_or_null("Tabs/UpgradeTab") as Button
	if back_button: back_button.pressed.connect(_on_back)
	if reset_button: reset_button.pressed.connect(_on_reset)
	if ship_tab: ship_tab.pressed.connect(func(): show_ships())
	if upgrade_tab: upgrade_tab.pressed.connect(func(): show_upgrades())
	show_ships()
	update_display()


func update_display():
	if credits_label: credits_label.text = "MegaCredits: " + str(save_manager.credits if save_manager else 0)
	if ship_info_label: ship_info_label.text = "Selected: " + Constants.SHIP_NAMES[save_manager.selected_ship if save_manager else 0]


func show_ships():
	selected_tab = 0
	ship_scroll.show()
	upgrade_scroll.hide()
	if ship_tab: ship_tab.add_theme_color_override("font_color", Color(0, 1, 1))
	if upgrade_tab: upgrade_tab.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	rebuild_ships()


func show_upgrades():
	selected_tab = 1
	ship_scroll.hide()
	upgrade_scroll.show()
	if ship_tab: ship_tab.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	if upgrade_tab: upgrade_tab.add_theme_color_override("font_color", Color(0, 1, 1))
	rebuild_upgrades()


func rebuild_ships():
	for c in ship_container.get_children():
		c.queue_free()
	for i in range(Constants.SHIP_COUNT):
		var ship_name = Constants.SHIP_NAMES[i]
		var desc = Constants.SHIP_DESCRIPTIONS[i]
		var cost = Constants.SHIP_COSTS[i]
		var unlocked = save_manager.unlocked_ships[i]
		var selected = i == save_manager.selected_ship

		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(1000, 80)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var hbox = HBoxContainer.new()
		panel.add_child(hbox)

		var name_label = Label.new()
		name_label.text = ship_name
		name_label.custom_minimum_size = Vector2(140, 0)
		name_label.add_theme_font_size_override("font_size", 18)
		if selected:
			name_label.add_theme_color_override("font_color", Color(0, 1, 1))

		var desc_label = Label.new()
		desc_label.text = desc
		desc_label.custom_minimum_size = Vector2(500, 0)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD

		var status_btn = Button.new()
		if selected:
			status_btn.text = "EQUIPPED"
			status_btn.disabled = true
		elif unlocked:
			status_btn.text = "EQUIP"
			status_btn.pressed.connect(func(ship=i): _equip_ship(ship))
		else:
			status_btn.text = "BUY: " + str(cost) + " MC"
			status_btn.pressed.connect(func(ship=i): _buy_ship(ship))

		hbox.add_child(name_label)
		hbox.add_child(desc_label)
		hbox.add_child(status_btn)
		ship_container.add_child(panel)


func rebuild_upgrades():
	for c in upgrade_container.get_children():
		c.queue_free()
	for i in range(Constants.UPGRADE_COUNT):
		var up_name = Constants.UPGRADE_NAMES[i]
		var level = save_manager.get_upgrade_level(i)
		var cost = Constants.UPGRADE_COSTS[i][level] if level < Constants.UPGRADE_MAX_LEVEL else 0
		var maxed = level >= Constants.UPGRADE_MAX_LEVEL

		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(1000, 60)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var hbox = HBoxContainer.new()
		panel.add_child(hbox)

		var name_label = Label.new()
		name_label.text = up_name
		name_label.custom_minimum_size = Vector2(160, 0)
		name_label.add_theme_font_size_override("font_size", 16)

		var level_label = Label.new()
		level_label.text = "Lv." + str(level) + "/" + str(Constants.UPGRADE_MAX_LEVEL)
		level_label.custom_minimum_size = Vector2(100, 0)

		var cost_btn = Button.new()
		if maxed:
			cost_btn.text = "MAXED"
			cost_btn.disabled = true
		else:
			cost_btn.text = str(cost) + " MC"
			cost_btn.pressed.connect(func(up=i): _buy_upgrade(up))

		var desc_label = Label.new()
		desc_label.text = _get_upgrade_desc(i, level)
		desc_label.custom_minimum_size = Vector2(400, 0)

		hbox.add_child(name_label)
		hbox.add_child(level_label)
		hbox.add_child(desc_label)
		hbox.add_child(cost_btn)
		upgrade_container.add_child(panel)


func _equip_ship(ship: int):
	save_manager.select_ship(ship)
	update_display()
	rebuild_ships()
	rebuild_upgrades()


func _buy_ship(ship: int):
	if save_manager.buy_ship(ship):
		update_display()
		rebuild_ships()


func _buy_upgrade(up: int):
	if save_manager.buy_upgrade(up):
		update_display()
		rebuild_upgrades()
		rebuild_ships()


func _on_back():
	hide()
	var gm = get_node("/root/GameManager")
	if gm: gm.change_state(gm.GameState.MENU)


func _on_reset():
	if save_manager: save_manager.reset_data()
	update_display()
	rebuild_ships()
	rebuild_upgrades()


func _get_upgrade_desc(up_type: int, level: int) -> String:
	match up_type:
		Constants.UpgradeType.MAX_HP: return "+" + str(level) + " HP"
		Constants.UpgradeType.SPEED: return "+" + str(level * 5) + "% speed"
		Constants.UpgradeType.FIRE_RATE: return "+" + str(level * 5) + "% fire rate"
		Constants.UpgradeType.DASH_CD: return "-" + str(level * 0.2) + "s dash cooldown"
		Constants.UpgradeType.SHIELD_DUR: return "+" + str(level * 0.5) + "s shield duration"
		Constants.UpgradeType.SCORE_MULT: return "x" + str(1.0 + level * 0.1) + " score"
		Constants.UpgradeType.START_WEAPON: return "Weapon Lv." + str(level)
	return ""
