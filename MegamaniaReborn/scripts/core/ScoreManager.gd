extends Node

var score := 0
var high_score := 0
var combo_count := 0
var combo_timer := 0.0
var score_multiplier := 1
const COMBO_TIMEOUT := 2.0

@onready var event_bus := get_node("/root/EventBus")


func _ready():
	_load_high_score()


func add_score(points: int):
	var multiplier = score_multiplier + (combo_count * 0.5)
	var final_points = int(points * multiplier)
	score += final_points
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	if event_bus:
		event_bus.score_changed.emit(score, final_points)
		event_bus.combo_updated.emit(combo_count)
	if score > high_score:
		high_score = score
		_save_high_score()


func get_total_score() -> int:
	return score


func reset_score():
	score = 0
	combo_count = 0
	combo_timer = 0.0
	if event_bus:
		event_bus.score_changed.emit(score, 0)
		event_bus.combo_updated.emit(combo_count)


func _process(delta):
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_count = 0
			if event_bus:
				event_bus.combo_updated.emit(0)


func _save_high_score():
	var config = ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.save("user://settings.cfg")


func _load_high_score():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		high_score = config.get_value("score", "high_score", 0)
