extends Control

# UI References
@onready var master_volume_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MasterVolumeContainer/MasterVolumeValue
@onready var music_volume_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/MusicVolumeContainer/MusicVolumeValue
@onready var sfx_volume_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/AudioSection/SFXVolumeContainer/SFXVolumeValue

@onready var fullscreen_checkbox = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/GraphicsSection/FullscreenContainer/FullscreenCheckBox
@onready var vsync_checkbox = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/GraphicsSection/VSyncContainer/VSyncCheckBox

@onready var mouse_sensitivity_slider = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/ControlsSection/MouseSensitivityContainer/MouseSensitivitySlider
@onready var mouse_sensitivity_value = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/ControlsSection/MouseSensitivityContainer/MouseSensitivityValue

@onready var apply_button = $Panel/VBoxContainer/ButtonsContainer/ApplyButton
@onready var reset_button = $Panel/VBoxContainer/ButtonsContainer/ResetButton
@onready var back_button = $Panel/VBoxContainer/ButtonsContainer/BackButton

# Settings data
var settings_data = {
	"master_volume": 100.0,
	"music_volume": 100.0,
	"sfx_volume": 100.0,
	"fullscreen": false,
	"vsync": true,
	"mouse_sensitivity": 1.0
}

var default_settings = {
	"master_volume": 100.0,
	"music_volume": 100.0,
	"sfx_volume": 100.0,
	"fullscreen": false,
	"vsync": true,
	"mouse_sensitivity": 1.0
}

const SETTINGS_FILE_PATH = "user://settings.save"

func _ready():
	load_settings()
	connect_signals()
	update_ui()

func connect_signals():
	# Volume sliders
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Graphics checkboxes
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	vsync_checkbox.toggled.connect(_on_vsync_toggled)
	
	# Controls
	mouse_sensitivity_slider.value_changed.connect(_on_mouse_sensitivity_changed)
	
	# Buttons
	apply_button.pressed.connect(_on_apply_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

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

func _on_mouse_sensitivity_changed(value: float):
	settings_data.mouse_sensitivity = value
	mouse_sensitivity_value.text = str(value)

func _on_apply_pressed():
	apply_settings()
	save_settings()
	print("Settings applied and saved!")

func _on_reset_pressed():
	settings_data = default_settings.duplicate()
	update_ui()
	print("Settings reset to default values")

func _on_back_pressed():
	# Go back to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Handle ESC key to go back
func _input(event):
	if event.is_action_pressed("esc"):
		_on_back_pressed()
