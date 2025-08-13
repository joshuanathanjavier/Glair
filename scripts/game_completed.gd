extends Control

@onready var play_again_button = $CenterContainer/VBoxContainer/PlayAgainButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton
@onready var completion_message_label = $CenterContainer/VBoxContainer/CompletionMessageLabel

var completion_message: String = "You found all the keys and escaped the forest!\nThe nightmare is over... for now."

func _ready():
	# Make sure mouse is visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Connect button signals
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Set completion message if provided
	if completion_message_label:
		completion_message_label.text = completion_message
	
	# Focus the play again button
	play_again_button.grab_focus()
	
	print("Game completed! Player successfully escaped!")

func _on_play_again_pressed():
	# Restart the current level
	get_tree().change_scene_to_file("res://scenes/map1.tscn")

func _on_main_menu_pressed():
	# Go to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_pressed():
	# Quit the game
	get_tree().quit()

func set_completion_message(message: String):
	completion_message = message
	if completion_message_label:
		completion_message_label.text = message
