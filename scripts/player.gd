extends CharacterBody3D


# --- Movement Settings ---
@export var move_speed: float = 3.0
@export var mouse_sensitivity: float = 0.002
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var sprint_multiplier: float = 1.8

# --- Stamina Settings ---
@export var max_stamina: float = 5.0
@export var stamina_depletion_rate: float = 1.0
@export var stamina_recovery_rate: float = 1.5

# --- Crouch Settings ---
@export var crouch_speed_multiplier: float = 0.5
@export var crouch_offset: float = -0.6  # How far camera drops when crouching

# --- State Variables ---
var y_velocity: float = 0.0
var stamina: float = max_stamina
var is_sprinting: bool = false
var is_crouching: bool = false
var camera_default_position: Vector3
var flashlight_on = false
var flashlight_battery: float = 100.0
var max_flashlight_battery: float = 100.0

# --- Node References ---
@onready var camera: Camera3D = $Camera3D
@onready var flashlight = $Camera3D/Flashlight
@onready var pause_menu = $"../UI/PauseMenu"

# --- Initialization ---
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_default_position = camera.position
	flashlight.visible = flashlight_on
	
	# Connect to settings changes
	Events.settings_changed.connect(_on_settings_changed)

# --- Mouse Look ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90.0, 90.0)

# --- Main Physics Logic ---
func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var forward = -transform.basis.z
	var right = transform.basis.x
	
	# Update UI via signals
	Events.stamina_updated.emit(stamina, max_stamina)
	Events.battery_updated.emit(flashlight_battery, max_flashlight_battery)

	# Flashlight Input
	if Input.is_action_just_pressed("flashlight_toggle"):
		flashlight_on = !flashlight_on
		flashlight.visible = flashlight_on

	# Flashlight battery drain
	if flashlight_on:
		flashlight_battery = max(0.0, flashlight_battery - delta * 5.0) # drains at 5 units per second
		if flashlight_battery == 0.0:
			flashlight_on = false
			flashlight.visible = false

	# Movement input
	if Input.is_action_pressed("move_forward"):
		direction += forward
	if Input.is_action_pressed("move_backward"):
		direction -= forward
	if Input.is_action_pressed("move_left"):
		direction -= right
	if Input.is_action_pressed("move_right"):
		direction += right

	direction = direction.normalized()

	# Gravity and jump
	if not is_on_floor():
		y_velocity -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump") and not is_crouching:
			y_velocity = jump_velocity
		else:
			y_velocity = 0.0

	# Crouch and camera adjustment
	is_crouching = Input.is_action_pressed("crouch")
	var target_camera_y = camera_default_position.y
	if is_crouching:
		target_camera_y += crouch_offset

	camera.position.y = lerp(camera.position.y, target_camera_y, 10 * delta)

	# Sprint and stamina logic
	is_sprinting = Input.is_action_pressed("run") and not is_crouching and stamina > 0.0 and direction != Vector3.ZERO

	var speed = move_speed
	if is_crouching:
		speed *= crouch_speed_multiplier
	if is_sprinting:
		speed *= sprint_multiplier
		stamina = max(0.0, stamina - stamina_depletion_rate * delta)
	elif not Input.is_action_pressed("run"):
		stamina = min(max_stamina, stamina + stamina_recovery_rate * delta)

	# Apply movement
	velocity = direction * speed
	velocity.y = y_velocity
	move_and_slide()
	
func _input(event):
		if event.is_action_pressed("esc"):  # default is Escape key
			if get_tree().paused:
				pause_menu.close()
			else:
				pause_menu.open()

func _on_settings_changed(settings_data: Dictionary):
	# Update mouse sensitivity when settings change
	if "mouse_sensitivity" in settings_data:
		mouse_sensitivity = settings_data.mouse_sensitivity * 0.002
