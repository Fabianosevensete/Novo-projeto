extends GutTest

const Constants = preload("res://scripts/utils/Constants.gd")


func test_initial_values():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	assert_eq(sm.credits, 0, "Should start with 0 credits")
	assert_eq(sm.selected_ship, Constants.ShipType.INTERCEPTOR, "Should start with INTERCEPTOR")
	assert_eq(sm.high_score, 0, "High score should be 0")


func test_add_spend_credits():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.add_credits(100)
	assert_eq(sm.credits, 100, "Credits should increase")

	var ok = sm.spend_credits(30)
	assert_true(ok, "Spending available credits should succeed")
	assert_eq(sm.credits, 70, "Credits should decrease")

	ok = sm.spend_credits(100)
	assert_false(ok, "Spending more than available should fail")
	assert_eq(sm.credits, 70, "Credits should remain unchanged")


func test_buy_upgrade_until_max():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.add_credits(99999)
	for level in range(Constants.UPGRADE_MAX_LEVEL + 1):
		var bought = sm.buy_upgrade(Constants.UpgradeType.MAX_HP)
		if level < Constants.UPGRADE_MAX_LEVEL:
			assert_true(bought, "Upgrade should be buyable at level %d" % level)
		else:
			assert_false(bought, "Upgrade should NOT be buyable at max level")
	assert_eq(sm.get_upgrade_level(Constants.UpgradeType.MAX_HP), Constants.UPGRADE_MAX_LEVEL)


func test_buy_upgrade_insufficient_credits():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	var bought = sm.buy_upgrade(Constants.UpgradeType.MAX_HP)
	assert_false(bought, "Should fail without credits")
	assert_eq(sm.get_upgrade_level(Constants.UpgradeType.MAX_HP), 0, "Level should stay 0")


func test_buy_ship():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.add_credits(99999)

	assert_true(sm.buy_ship(1), "Ship 1 should be buyable")
	assert_true(sm.unlocked_ships[1], "Ship 1 should be unlocked")


func test_buy_ship_already_unlocked():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	assert_false(sm.buy_ship(0), "Already-unlocked ship 0 should return false")


func test_buy_ship_invalid_index():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.add_credits(99999)
	assert_false(sm.buy_ship(-1), "Negative index should fail")
	assert_false(sm.buy_ship(99), "Out-of-range index should fail")


func test_select_ship():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.select_ship(0)
	assert_eq(sm.selected_ship, 0, "Should select ship 0")


func test_select_ship_invalid():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.select_ship(99)
	assert_eq(sm.selected_ship, Constants.ShipType.INTERCEPTOR, "Should reject invalid ship index")


func test_select_ship_locked():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.select_ship(2)
	assert_eq(sm.selected_ship, Constants.ShipType.INTERCEPTOR, "Should reject locked ship")


func test_has_upgrade():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.add_credits(99999)
	sm.buy_upgrade(Constants.UpgradeType.MAX_HP)
	assert_true(sm.has_upgrade(Constants.UpgradeType.MAX_HP), "Should have purchased upgrade")
	assert_false(sm.has_upgrade(Constants.UpgradeType.SPEED), "Should not have unpurchased upgrade")


func test_save_data_produces_no_errors():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.add_credits(500)
	sm.high_score = 9999
	sm.save_data()
	assert_eq(sm.credits, 500, "Credits unchanged after save")
	assert_eq(sm.high_score, 9999, "High score unchanged after save")


func test_reset_data():
	var sm = autofree(load("res://scripts/utils/SaveManager.gd").new())
	sm.add_credits(500)
	sm.buy_ship(2)
	sm.reset_data()
	assert_eq(sm.credits, 0, "Credits should reset to 0")
	assert_false(sm.unlocked_ships[2], "Ship 2 should be locked after reset")
	assert_eq(sm.high_score, 0, "High score should reset")
