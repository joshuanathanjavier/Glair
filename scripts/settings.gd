extends Control

# Track where we came from to navigate back correctly
var previous_scene: String = ""

# UI References
@onready var master_volume_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MasterVolumeContainer/MasterVolumeValue
@onready var music_volume_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MusicVolumeContainer/MusicVolumeValue
@onready var sfx_volume_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/SFXVolumeContainer/SFXVolumeValue

@onready var fullscreen_checkbox = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/GraphicsSection/FullscreenContainer/FullscreenCheckBox
@onready var vsync_checkbox = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/GraphicsSection/VSyncContainer/VSyncCheckBox
@onready var crosshair_checkbox = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/GraphicsSection/CrosshairContainer/CrosshairCheckBox

@onready var mouse_sensitivity_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/ControlsSection/MouseSensitivityContainer/MouseSensitivitySlider
@onready var mouse_sensitivity_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/ControlsSection/MouseSensitivityContainer/MouseSensitivityValue

@onready var apply_button = $Panel/VBoxContainer/ButtonsContainer/ApplyButton
@onready var reset_button = $Panel/VBoxContainer/ButtonsContainer/ResetButton
@onready var back_button = $Panel/VBoxContainer/ButtonsContainer/BackButton
@onready var hover_audio = $HoverAudio
@onready var click_audio = $ClickAudio

# Settings data
var settings_data = {
	"master_volume": 100.0,
	"music_volume": 100.0,
	"sfx_volume": 100.0,
	"fullscreen": false,
	"vsync": true,
	"mouse_sensitivity": 1.0,
	"show_crosshair": true
}

var default_settings = {
	"master_volume": 100.0,
	"music_volume": 100.0,
	"sfx_volume": 100.0,
	"fullscreen": false,
	"vsync": true,
	"mouse_sensitivity": 1.0,
	"show_crosshair": true
}

const SETTINGS_FILE_PATH = "user://settings.save"

func _ready():
	# Check if we came from pause menu (from tree metadata or set directly)
	if get_tree().has_meta("came_from_pause") or previous_scene == "pause_menu":
		previous_scene = "pause_menu"
		get_tree().remove_meta("came_from_pause")  # Clean up if it exists
	else:
		previous_scene = "main_menu"
		# Emit menu opened signal if we're in a game scene (not from main menu)
		if get_tree().current_scene.scene_file_path != "res://scenes/main_menu.tscn":
			Events.menu_opened.emit()
	
	load_settings()
	connect_signals()
	update_ui()

# Function to set the previous scene externally
func set_previous_scene(scene_name: String):
	previous_scene = scene_name

func connect_signals():
	# Volume sliders
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Graphics checkboxes
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	vsync_checkbox.toggled.connect(_on_vsync_toggled)
	crosshair_checkbox.toggled.connect(_on_crosshair_toggled)
	
	# Controls
	mouse_sensitivity_slider.value_changed.connect(_on_mouse_sensitivity_changed)
	
	# Buttons
	apply_button.pressed.connect(_on_apply_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect hover signals for audio feedback
	apply_button.mouse_entered.connect(_on_button_hover)
	reset_button.mouse_entered.connect(_on_button_hover)
	back_button.mouse_entered.connect(_on_button_hover)

func load_settings():
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var loaded_data = json.data
				# Merge loaded data with defaults to ensure all keys exist
				for key in default_settings.keys():
					if key in loaded_data:
						settings_data[key] = loaded_data[key]
			else:
				print("Error parsing settings file")
	else:
		# Use default settings
		settings_data = default_settings.duplicate()
	
	apply_settings()

func save_settings():
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(settings_data)
		file.store_string(json_string)
		file.close()
		print("Settings saved successfully")
	else:
		print("Error saving settings file")

func apply_settings():
	# Apply audio settings
	var master_bus_index = AudioServer.get_bus_index("Master")
	var music_bus_index = AudioServer.get_bus_index("Music") if AudioServer.get_bus_count() > 1 else -1
	var sfx_bus_index = AudioServer.get_bus_index("SFX") if AudioServer.get_bus_count() > 2 else -1
	
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(settings_data.master_volume / 100.0))
	
	if music_bus_index != -1:
		AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(settings_data.music_volume / 100.0))
	
	if sfx_bus_index != -1:
		AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(settings_data.sfx_volume / 100.0))
	
	# Apply graphics settings
	if settings_data.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if settings_data.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Mouse sensitivity is typically handled by the player controller
	# We'll emit a signal for other scripts to listen to
	Events.settings_changed.emit(settings_data)
	Events.crosshair_visibility_changed.emit(settings_data.show_crosshair)

func update_ui():
	# Update volume sliders and labels
	master_volume_slider.value = settings_data.master_volume
	master_volume_value.text = str(int(settings_data.master_volume)) + "%"
	
	music_volume_slider.value = settings_data.music_volume
	music_volume_value.text = str(int(settings_data.music_volume)) + "%"
	
	sfx_volume_slider.value = settings_data.sfx_volume
	sfx_volume_value.text = str(int(settings_data.sfx_volume)) + "%"
	
	# Update graphics checkboxes
	fullscreen_checkbox.button_pressed = settings_data.fullscreen
	vsync_checkbox.button_pressed = settings_data.vsync
	crosshair_checkbox.button_pressed = settings_data.show_crosshair
	
	# Update mouse sensitivity
	mouse_sensitivity_slider.value = settings_data.mouse_sensitivity
	mouse_sensitivity_value.text = str(settings_data.mouse_sensitivity)

# Signal handlers
func _on_master_volume_changed(value: float):
	settings_data.master_volume = value
	master_volume_value.text = str(int(value)) + "%"

func _on_music_volume_changed(value: float):
	settings_data.music_volume = value
	music_volume_value.text = str(int(value)) + "%"

func _on_sfx_volume_changed(value: float):
	settings_data.sfx_volume = value
	sfx_volume_value.text = str(int(value)) + "%"

func _on_fullscreen_toggled(pressed: bool):
	settings_data.fullscreen = pressed

func _on_vsync_toggled(pressed: bool):
	settings_data.vsync = pressed

func _on_crosshair_toggled(pressed: bool):
	settings_data.show_crosshair = pressed
	# Update UI immediately to show the crosshair change
	Events.crosshair_visibility_changed.emit(pressed)

func _on_mouse_sensitivity_changed(value: float):
	settings_data.mouse_sensitivity = value
	mouse_sensitivity_value.text = str(value)

func _on_apply_pressed():
	# Play click sound
	if click_audio and click_audio.stream:
		click_audio.play()
	
	apply_settings()
	save_settings()
	print("Settings applied and saved!")

func _on_reset_pressed():
	# Play click sound
	if click_audio and click_audio.stream:
		click_audio.play()
	
	settings_data = default_settings.duplicate()
	update_ui()
	print("Settings reset to default values")

func _on_back_pressed():
	# Play click sound
	if click_audio and click_audio.stream:
		click_audio.play()
	
	if previous_scene == "pause_menu":
		# Emit signal to go back to pause menu instead of changing scenes
		Events.settings_back_to_pause.emit()
	else:
		# Going back to main menu - emit menu closed signal since we're leaving the game
		Events.menu_closed.emit()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Handle ESC key to go back
func _input(event):
	if event.is_action_pressed("esc"):
		_on_back_pressed()

func _on_button_hover():
	# Play hover sound when mouse enters buttons
	if hover_audio and hover_audio.stream:
		hover_audio.play()
