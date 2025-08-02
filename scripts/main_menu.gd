extends Control

@onready var start_button = $Panel/VBoxContainer/StartButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/map1.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
