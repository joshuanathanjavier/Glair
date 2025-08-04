extends CanvasLayer

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var restart_button = $Panel/VBoxContainer/RestartButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton

var settings_scene: Control = null

func _ready():
	hide()
	
	# Ensure this CanvasLayer appears above player UI
	layer = 10  # Higher layer number means it appears on top
	
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Connect to settings back signal
	Events.settings_back_to_pause.connect(_on_settings_back)

func open():
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Emit menu opened signal to hide UI elements
	print("PauseMenu: Opening menu, emitting menu_opened signal")
	Events.menu_opened.emit()

func close():
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Emit menu closed signal to restore UI elements
	print("PauseMenu: Closing menu, emitting menu_closed signal")
	Events.menu_closed.emit()

func _on_resume_pressed():
	close()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_settings_pressed():
	# Load settings as an overlay instead of changing scene
	var settings_scene_resource = preload("res://scenes/settings.tscn")
	settings_scene = settings_scene_resource.instantiate()
	
	# Hide pause menu panel but keep the canvas layer
	$Panel.hide()
	
	# Add settings to this canvas layer
	add_child(settings_scene)
	
	# Tell settings it came from pause menu
	settings_scene.set_previous_scene("pause_menu")
	
	# Settings is still a menu, so no need to emit menu_closed signal

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_settings_back():
	# Remove settings overlay and show pause menu again
	if settings_scene:
		settings_scene.queue_free()
		settings_scene = null
	
	# Show pause menu panel again
	$Panel.show()
