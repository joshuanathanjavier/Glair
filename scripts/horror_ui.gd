extends CanvasLayer

# Node references
@onready var hud_container: Control = $HUD
@onready var stamina_bar: ProgressBar = $HUD/UIContainer/VBoxContainer/StaminaContainer/StaminaBar
@onready var flashlight_bar: ProgressBar = $HUD/UIContainer/VBoxContainer/FlashlightContainer/FlashlightBar
@onready var stamina_label: Label = $HUD/UIContainer/VBoxContainer/StaminaContainer/StaminaLabel
@onready var flashlight_label: Label = $HUD/UIContainer/VBoxContainer/FlashlightContainer/FlashlightLabel
@onready var crosshair: Control = $HUD/Crosshair
@onready var crosshair_dot: Panel = $HUD/Crosshair/CrosshairDot

# Theme resources
var base_theme: Theme
var stamina_theme: Theme
var battery_theme: Theme
var stamina_warning_theme: Theme
var battery_warning_theme: Theme

# Warning thresholds
const STAMINA_WARNING_THRESHOLD = 20.0
const BATTERY_WARNING_THRESHOLD = 25.0

# Animation variables
var stamina_warning_active = false
var battery_warning_active = false
var tween: Tween

# Warning state tracking
var stamina_warning_sent = false
var battery_warning_sent = false

func _ready():
	# Add to UI group for settings integration
	add_to_group("ui")
	
	# Ensure this CanvasLayer is behind menus (lower layer number)
	layer = 0  # Player UI should be on a lower layer than menus
	
	# Load base theme
	base_theme = preload("res://themes/horror_ui_theme.tres")
	
	# Create custom themes for each bar
	_create_custom_themes()
	
	# Apply initial themes
	if stamina_bar:
		stamina_bar.theme = stamina_theme
	if flashlight_bar:
		flashlight_bar.theme = battery_theme
	
	# Initialize crosshair
	_setup_crosshair()
	
	# Connect to player state signals
	Events.stamina_updated.connect(_on_stamina_updated)
	Events.battery_updated.connect(_on_battery_updated)
	# Connect to warning signals
	Events.low_stamina_warning.connect(_on_low_stamina_warning)
	Events.low_battery_warning.connect(_on_low_battery_warning)
	# Connect to crosshair visibility signal
	Events.crosshair_visibility_changed.connect(_on_crosshair_visibility_changed)
	
	# Connect to menu state signals to hide UI elements when menus are open
	Events.menu_opened.connect(_on_menu_opened)
	Events.menu_closed.connect(_on_menu_closed)

# Store original visibility states
var original_crosshair_visible: bool = true
var menu_is_open: bool = false

func _create_custom_themes():
	# Create stamina theme
	stamina_theme = Theme.new()
	var stamina_bg = StyleBoxFlat.new()
	stamina_bg.bg_color = Color(0.1, 0.15, 0.12, 0.9)
	stamina_bg.border_width_left = 1
	stamina_bg.border_width_top = 1
	stamina_bg.border_width_right = 1
	stamina_bg.border_width_bottom = 1
	stamina_bg.border_color = Color(0.2, 0.3, 0.25, 1)
	stamina_bg.corner_radius_top_left = 3
	stamina_bg.corner_radius_top_right = 3
	stamina_bg.corner_radius_bottom_right = 3
	stamina_bg.corner_radius_bottom_left = 3
	
	var stamina_fill = StyleBoxFlat.new()
	stamina_fill.bg_color = Color(0.2, 0.7, 0.5, 0.9)
	stamina_fill.border_width_left = 1
	stamina_fill.border_width_top = 1
	stamina_fill.border_width_right = 1
	stamina_fill.border_width_bottom = 1
	stamina_fill.border_color = Color(0.3, 0.8, 0.6, 1)
	stamina_fill.corner_radius_top_left = 3
	stamina_fill.corner_radius_top_right = 3
	stamina_fill.corner_radius_bottom_right = 3
	stamina_fill.corner_radius_bottom_left = 3
	
	stamina_theme.set_stylebox("background", "ProgressBar", stamina_bg)
	stamina_theme.set_stylebox("fill", "ProgressBar", stamina_fill)
	
	# Create battery theme
	battery_theme = Theme.new()
	var battery_bg = StyleBoxFlat.new()
	battery_bg.bg_color = Color(0.15, 0.12, 0.08, 0.9)
	battery_bg.border_width_left = 1
	battery_bg.border_width_top = 1
	battery_bg.border_width_right = 1
	battery_bg.border_width_bottom = 1
	battery_bg.border_color = Color(0.3, 0.25, 0.15, 1)
	battery_bg.corner_radius_top_left = 3
	battery_bg.corner_radius_top_right = 3
	battery_bg.corner_radius_bottom_right = 3
	battery_bg.corner_radius_bottom_left = 3
	
	var battery_fill = StyleBoxFlat.new()
	battery_fill.bg_color = Color(0.9, 0.8, 0.2, 0.9)
	battery_fill.border_width_left = 1
	battery_fill.border_width_top = 1
	battery_fill.border_width_right = 1
	battery_fill.border_width_bottom = 1
	battery_fill.border_color = Color(1, 0.9, 0.3, 1)
	battery_fill.corner_radius_top_left = 3
	battery_fill.corner_radius_top_right = 3
	battery_fill.corner_radius_bottom_right = 3
	battery_fill.corner_radius_bottom_left = 3
	
	battery_theme.set_stylebox("background", "ProgressBar", battery_bg)
	battery_theme.set_stylebox("fill", "ProgressBar", battery_fill)
	
	# Create warning themes
	stamina_warning_theme = Theme.new()
	var stamina_warning_fill = StyleBoxFlat.new()
	stamina_warning_fill.bg_color = Color(0.8, 0.15, 0.15, 0.95)
	stamina_warning_fill.border_width_left = 1
	stamina_warning_fill.border_width_top = 1
	stamina_warning_fill.border_width_right = 1
	stamina_warning_fill.border_width_bottom = 1
	stamina_warning_fill.border_color = Color(0.9, 0.2, 0.2, 1)
	stamina_warning_fill.corner_radius_top_left = 3
	stamina_warning_fill.corner_radius_top_right = 3
	stamina_warning_fill.corner_radius_bottom_right = 3
	stamina_warning_fill.corner_radius_bottom_left = 3
	
	stamina_warning_theme.set_stylebox("background", "ProgressBar", stamina_bg)
	stamina_warning_theme.set_stylebox("fill", "ProgressBar", stamina_warning_fill)
	
	battery_warning_theme = Theme.new()
	var battery_warning_fill = StyleBoxFlat.new()
	battery_warning_fill.bg_color = Color(0.9, 0.4, 0.1, 0.95)
	battery_warning_fill.border_width_left = 1
	battery_warning_fill.border_width_top = 1
	battery_warning_fill.border_width_right = 1
	battery_warning_fill.border_width_bottom = 1
	battery_warning_fill.border_color = Color(1, 0.5, 0.2, 1)
	battery_warning_fill.corner_radius_top_left = 3
	battery_warning_fill.corner_radius_top_right = 3
	battery_warning_fill.corner_radius_bottom_right = 3
	battery_warning_fill.corner_radius_bottom_left = 3
	
	battery_warning_theme.set_stylebox("background", "ProgressBar", battery_bg)
	battery_warning_theme.set_stylebox("fill", "ProgressBar", battery_warning_fill)

func _on_stamina_updated(current_stamina: float, max_stamina: float):
	if stamina_bar:
		stamina_bar.value = (current_stamina / max_stamina) * 100.0
		
		# Check for warning state
		var percentage = (current_stamina / max_stamina) * 100.0
		if percentage <= STAMINA_WARNING_THRESHOLD and not stamina_warning_sent:
			Events.low_stamina_warning.emit()
			stamina_warning_sent = true
		elif percentage > STAMINA_WARNING_THRESHOLD:
			stamina_warning_sent = false
			if stamina_warning_active:
				_stop_stamina_warning()

func _on_battery_updated(current_battery: float, max_battery: float):
	if flashlight_bar:
		flashlight_bar.value = (current_battery / max_battery) * 100.0
		
		# Check for warning state
		var percentage = (current_battery / max_battery) * 100.0
		if percentage <= BATTERY_WARNING_THRESHOLD and not battery_warning_sent:
			Events.low_battery_warning.emit()
			battery_warning_sent = true
		elif percentage > BATTERY_WARNING_THRESHOLD:
			battery_warning_sent = false
			if battery_warning_active:
				_stop_battery_warning()

func _start_stamina_warning():
	stamina_warning_active = true
	if stamina_bar and stamina_warning_theme:
		stamina_bar.theme = stamina_warning_theme
	_pulse_stamina_bar()

func _stop_stamina_warning():
	stamina_warning_active = false
	if tween:
		tween.kill()
	if stamina_bar and stamina_theme:
		stamina_bar.theme = stamina_theme
		stamina_bar.modulate = Color.WHITE

func _start_battery_warning():
	battery_warning_active = true
	if flashlight_bar and battery_warning_theme:
		flashlight_bar.theme = battery_warning_theme
	_flicker_flashlight_bar()

func _stop_battery_warning():
	battery_warning_active = false
	if tween:
		tween.kill()
	if flashlight_bar and battery_theme:
		flashlight_bar.theme = battery_theme
		flashlight_bar.modulate = Color.WHITE

func _pulse_stamina_bar():
	if not stamina_warning_active or not stamina_bar:
		return
		
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(stamina_bar, "modulate", Color(1.3, 0.7, 0.7, 1.0), 0.6)
	tween.tween_property(stamina_bar, "modulate", Color.WHITE, 0.6)

func _flicker_flashlight_bar():
	if not battery_warning_active or not flashlight_bar:
		return
		
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(flashlight_bar, "modulate", Color(1.2, 1.1, 0.7, 1.0), 0.15)
	tween.tween_property(flashlight_bar, "modulate", Color(0.8, 0.7, 0.4, 1.0), 0.15)
	tween.tween_property(flashlight_bar, "modulate", Color(1.1, 1.0, 0.6, 1.0), 0.1)
	tween.tween_property(flashlight_bar, "modulate", Color.WHITE, 0.2)

func _on_low_stamina_warning():
	_start_stamina_warning()

func _on_low_battery_warning():
	_start_battery_warning()

func update_stamina(current_stamina: float, max_stamina: float):
	_on_stamina_updated(current_stamina, max_stamina)

func _setup_crosshair():
	if crosshair_dot:
		# Create a round crosshair dot style
		var crosshair_style = StyleBoxFlat.new()
		crosshair_style.bg_color = Color(1, 1, 1, 0.9)  # More opaque white
		crosshair_style.corner_radius_top_left = 2
		crosshair_style.corner_radius_top_right = 2
		crosshair_style.corner_radius_bottom_left = 2
		crosshair_style.corner_radius_bottom_right = 2
		crosshair_style.border_width_left = 1
		crosshair_style.border_width_top = 1
		crosshair_style.border_width_right = 1
		crosshair_style.border_width_bottom = 1
		crosshair_style.border_color = Color(0, 0, 0, 0.7)  # More visible black border
		
		crosshair_dot.add_theme_stylebox_override("panel", crosshair_style)
		
	# Load crosshair visibility setting
	_load_crosshair_setting()

func _load_crosshair_setting():
	# Default to enabled if no setting exists
	var settings = load_settings_data()
	var show_crosshair = settings.get("show_crosshair", true)
	original_crosshair_visible = show_crosshair
	set_crosshair_visible(show_crosshair)

func set_crosshair_visible(visible: bool):
	if crosshair:
		crosshair.visible = visible

func _on_crosshair_visibility_changed(visible: bool):
	original_crosshair_visible = visible
	# Only apply crosshair setting if menu is not open (HUD is visible)
	if not menu_is_open and hud_container and hud_container.visible:
		set_crosshair_visible(visible)

func _on_menu_opened():
	menu_is_open = true
	print("HorrorUI: Menu opened, hiding HUD")
	# Hide entire HUD when menu is opened
	if hud_container:
		hud_container.visible = false

func _on_menu_closed():
	menu_is_open = false
	print("HorrorUI: Menu closed, showing HUD")
	# Show entire HUD when menu is closed
	if hud_container:
		hud_container.visible = true
	# Restore crosshair visibility to its original state (in case it was disabled in settings)
	set_crosshair_visible(original_crosshair_visible)

func load_settings_data() -> Dictionary:
	# Try to load settings from file, return defaults if file doesn't exist
	const SETTINGS_FILE_PATH = "user://settings.save"
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
		if file:
			var settings_text = file.get_as_text()
			file.close()
			var json = JSON.new()
			var parse_result = json.parse(settings_text)
			if parse_result == OK:
				return json.data
	
	# Return default settings if file doesn't exist or parsing failed
	return {
		"master_volume": 100.0,
		"music_volume": 100.0,
		"sfx_volume": 100.0,
		"fullscreen": false,
		"vsync": true,
		"mouse_sensitivity": 1.0,
		"show_crosshair": true
	}

func update_flashlight(current_battery: float, max_battery: float):
	_on_battery_updated(current_battery, max_battery)
