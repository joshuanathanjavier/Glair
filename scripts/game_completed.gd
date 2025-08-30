extends Control

@onready var play_again_button = $CenterContainer/VBoxContainer/PlayAgainButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton
@onready var completion_message_label = $CenterContainer/VBoxContainer/CompletionMessageLabel
@onready var time_finished_label = $CenterContainer/VBoxContainer/TimeFinishedLabel

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
	
	# Update the time finished label with actual completion time
	_update_time_finished_label()
	
	# Focus the play again button
	play_again_button.grab_focus()
	
	print("Game completed! Player successfully escaped!")

func _on_play_again_pressed():
	# Restart the current level
	get_tree().change_scene_to_file("res://scenes/map/map1.tscn")

func _on_main_menu_pressed():
	# Go to main menu
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_quit_pressed():
	# Quit the game
	get_tree().quit()

func set_completion_message(message: String):
	completion_message = message
	if completion_message_label:
		completion_message_label.text = message

func _update_time_finished_label():
	if time_finished_label:
		# Get the completion time from the Events autoload
		var completion_time = Events.game_completion_time
		print("DEBUG: Game completed script - completion time: ", completion_time)
		
		if completion_time > 0.0:
			# Format the time into minutes and seconds
			var minutes = int(completion_time) / 60
			var seconds = int(completion_time) % 60
			
			# Format the time text with proper grammar
			var time_text = ""
			if minutes > 0:
				if minutes == 1:
					time_text += "1 minute"
				else:
					time_text += "%d minutes" % minutes
				
				if seconds > 0:
					if seconds == 1:
						time_text += " and 1 second"
					else:
						time_text += " and %d seconds" % seconds
				else:
					time_text += " and 0 seconds"
			else:
				if seconds == 1:
					time_text = "1 second"
				else:
					time_text = "%d seconds" % seconds
			
			# Update the label text
			time_finished_label.text = "Completed in " + time_text
			print("DEBUG: Updated time label to: ", time_finished_label.text)
		else:
			# If no completion time is available, show a default message
			time_finished_label.text = "Game completed successfully!"
			print("DEBUG: No completion time available, showing default message")

func set_completion_time(completion_time: float):
	"""Set the completion time externally (useful for testing or custom time tracking)"""
	# Store the completion time in Events autoload
	Events.game_completion_time = completion_time
	
	if time_finished_label:
		var minutes = int(completion_time) / 60
		var seconds = int(completion_time) % 60
		
		# Format the time text with proper grammar
		var time_text = ""
		if minutes > 0:
			if minutes == 1:
				time_text += "1 minute"
			else:
				time_text += "%d minutes" % minutes
			
			if seconds > 0:
				if seconds == 1:
					time_text += " and 1 second"
				else:
					time_text += " and %d seconds" % seconds
			else:
				time_text += " and 0 seconds"
		else:
			if seconds == 1:
				time_text = "1 second"
			else:
				time_text = "%d seconds" % seconds
		
		# Update the label text
		time_finished_label.text = "Completed in " + time_text
