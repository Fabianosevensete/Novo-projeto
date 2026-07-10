extends Control

const Constants = preload("res://scripts/utils/Constants.gd")

@onready var save_manager: SaveManager
@onready var credits_label: Label = $CreditsLabel
@onready var ship_container: VBoxContainer = $ShipScroll/ShipContainer
@onready var upgrade_container: VBoxContainer = $UpgradeScroll/UpgradeContainer
@onready var back_button: Button = $BottomBar/BackButton
@onready var ship_info_label: Label = $ShipInfoLabel
@onready var reset_button: Button = $BottomBar/ResetButton
@onready var ship_scroll: ScrollContainer = $ShipScroll
@onready var upgrade_scroll: ScrollContainer = $UpgradeScroll

var selected_tab := 0  # 0 = ships, 1 = upgrades


func _ready():
	save_manager = get_node("/root/SaveManager")
	back_button.pressed.connect(_on_back)
	reset_button.pressed.connect(_on_reset)
	var tab_ship = $Tabs/ShipTab
	var tab_upgrade = $Tabs/UpgradeTab
	if tab_ship:
		tab_ship.pressed.connect(func(): show_ships())
	if tab_upgrade:
		tab_upgrade.pressed.connect(func(): show_upgrades())
	show_ships()
	update_display()


func update_display():
	credits_label.text = "MegaCredits: " + str(save_manager.credits)
	ship_info_label.text = "Selected: " + Constants.SHIP_NAMES[save_manager.selected_ship]


func show_ships():
	selected_tab = 0
	ship_scroll.show()
	upgrade_scroll.hide()
	%ShipTab.add_theme_color_override("font_color", Color(0, 1, 1))
	%UpgradeTab.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	rebuild_ships()


func show_upgrades():
	selected_tab = 1
	ship_scroll.hide()
	upgrade_scroll.show()
	%ShipTab.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	%UpgradeTab.add_theme_color_override("font_color", Color(0, 1, 1))
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
	get_node("/root/GameManager").change_state(get_node("/root/GameManager").GameState.MENU)


func _on_reset():
	save_manager.reset_data()
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
