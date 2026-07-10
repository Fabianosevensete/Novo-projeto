extends Node

func _init():
	if not get_tree().root.has_node("EventBus"):
		var eb = load("res://scripts/core/EventBus.gd").new()
		get_tree().root.add_child(eb)
		eb.name = "EventBus"
	if not get_tree().root.has_node("GameManager"):
		var gm = load("res://scripts/core/GameManager.gd").new()
		get_tree().root.add_child(gm)
		gm.name = "GameManager"
	if not get_tree().root.has_node("ScoreManager"):
		var sm = load("res://scripts/core/ScoreManager.gd").new()
		get_tree().root.add_child(sm)
		sm.name = "ScoreManager"
