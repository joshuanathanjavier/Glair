extends Control

@onready var start_button = $Panel/MenuContainer/ButtonGroup/StartButton
@onready var settings_button = $Panel/MenuContainer/ButtonGroup/SettingsButton
@onready var quit_button = $Panel/MenuContainer/ButtonGroup/QuitButton
@onready var menu_audio = $MenuAudio
@onready var hover_audio = $HoverAudio
@onready var click_audio = $ClickAudio

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect hover signals for audio feedback
	start_button.mouse_entered.connect(_on_button_hover)
	settings_button.mouse_entered.connect(_on_button_hover)
	quit_button.mouse_entered.connect(_on_button_hover)
	
	# Connect audio finished signal for looping
	if menu_audio:
		menu_audio.finished.connect(_on_audio_finished)
	
	# Start playing main menu audio
	if menu_audio and menu_audio.stream:
		menu_audio.play()

func _on_start_pressed():
	# Play click sound
	if click_audio and click_audio.stream:
		click_audio.play()
	
	# Stop menu audio before transitioning
	if menu_audio and menu_audio.playing:
		menu_audio.stop()
	get_tree().change_scene_to_file("res://scenes/map/map1.tscn")

func _on_settings_pressed():
	# Play click sound
	if click_audio and click_audio.stream:
		click_audio.play()
	
	# Stop menu audio before transitioning
	if menu_audio and menu_audio.playing:
		menu_audio.stop()
	get_tree().change_scene_to_file("res://scenes/ui/settings.tscn")

func _on_quit_pressed():
	# Play click sound
	if click_audio and click_audio.stream:
		click_audio.play()
	
	get_tree().quit()

func _on_audio_finished():
	# Restart the main menu audio when it finishes
	if menu_audio and menu_audio.stream:
		menu_audio.play()

func _on_button_hover():
	# Play hover sound when mouse enters buttons
	if hover_audio and hover_audio.stream:
		hover_audio.play()
