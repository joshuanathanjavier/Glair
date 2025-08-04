extends CanvasLayer

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var restart_button = $Panel/VBoxContainer/RestartButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton

func _ready():
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func open():
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed():
	close()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_settings_pressed():
	# Set a flag to indicate we came from pause menu
	get_tree().set_meta("came_from_pause", true)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
