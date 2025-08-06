extends Control

@onready var restart_button = $CenterContainer/VBoxContainer/RestartButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton
@onready var death_reason_label = $CenterContainer/VBoxContainer/DeathReasonLabel

var death_reason: String = "You were consumed by the darkness..."

func _ready():
	# Make sure mouse is visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Connect button signals
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Set death reason if provided
	if death_reason_label:
		death_reason_label.text = death_reason
	
	# Focus the restart button
	restart_button.grab_focus()

func _on_restart_pressed():
	# Restart the current level
	get_tree().change_scene_to_file("res://scenes/map1.tscn")

func _on_main_menu_pressed():
	# Go to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_pressed():
	# Quit the game
	get_tree().quit()

func set_death_reason(reason: String):
	death_reason = reason
	if death_reason_label:
		death_reason_label.text = reason
