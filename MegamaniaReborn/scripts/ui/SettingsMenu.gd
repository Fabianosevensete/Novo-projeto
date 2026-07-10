extends CanvasLayer

@onready var sfx_slider := $VBox/SFXSlider
@onready var music_slider := $VBox/MusicSlider
@onready var sfx_value := $VBox/SFXValue
@onready var music_value := $VBox/MusicValue
@onready var back_btn := $VBox/BackBtn


func _ready():
	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)
	back_btn.pressed.connect(_on_back)
	var save = get_node("/root/SaveManager")
	sfx_slider.value = save.sfx_volume
	music_slider.value = save.music_volume
	_update_labels()


func _on_sfx_changed(value: float):
	var save = get_node("/root/SaveManager")
	save.sfx_volume = value
	save.save_data()
	var audio = get_node("/root/AudioManager")
	audio.set_sfx_volume(value)
	_update_labels()


func _on_music_changed(value: float):
	var save = get_node("/root/SaveManager")
	save.music_volume = value
	save.save_data()
	var audio = get_node("/root/AudioManager")
	audio.set_music_volume(value)
	_update_labels()


func _update_labels():
	sfx_value.text = str(int(sfx_slider.value)) + " dB"
	music_value.text = str(int(music_slider.value)) + " dB"


func _on_back():
	visible = false
	var gm = get_node("/root/GameManager")
	var main = gm.main_scene
	if main:
		if gm.current_state == gm.GameState.PLAYING or gm.current_state == gm.GameState.PAUSED:
			if main.pause_menu:
				main.pause_menu.visible = true
		else:
			if main.main_menu:
				main.main_menu.visible = true
